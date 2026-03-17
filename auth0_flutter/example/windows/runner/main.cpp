#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <sddl.h>
#include <string>
#include <vector>
#include <thread>

#include "flutter_window.h"
#include "utils.h"

const wchar_t* kSingleInstanceMutex = L"auth0flutter_single_instance_mutex";
const wchar_t* kRedirectPipeName    = L"\\\\.\\pipe\\auth0flutter_pipe";

// Only URLs beginning with this prefix are accepted from the pipe.
// Matches kDefaultRedirectUri in oauth_helpers.h.
const wchar_t* kCallbackPrefix = L"auth0flutter://callback";

// Builds a SECURITY_DESCRIPTOR that grants pipe read/write access only to the
// current user's SID, preventing other users or processes from connecting.
// Returns NULL on failure. Caller must LocalFree() the returned pointer.
static PSECURITY_DESCRIPTOR BuildCurrentUserSD() {
  HANDLE hToken = NULL;
  if (!OpenProcessToken(GetCurrentProcess(), TOKEN_QUERY, &hToken))
    return NULL;

  // Query required buffer size, then fetch the token user info.
  DWORD cbTokenUser = 0;
  GetTokenInformation(hToken, TokenUser, NULL, 0, &cbTokenUser);
  if (GetLastError() != ERROR_INSUFFICIENT_BUFFER) {
    CloseHandle(hToken);
    return NULL;
  }

  std::vector<BYTE> buf(cbTokenUser);
  auto* pTokenUser = reinterpret_cast<PTOKEN_USER>(buf.data());
  if (!GetTokenInformation(hToken, TokenUser, pTokenUser, cbTokenUser, &cbTokenUser)) {
    CloseHandle(hToken);
    return NULL;
  }
  CloseHandle(hToken);

  // Convert the SID to a string so we can embed it in an SDDL expression.
  LPWSTR pszSid = NULL;
  if (!ConvertSidToStringSidW(pTokenUser->User.Sid, &pszSid))
    return NULL;

  // D:(A;;GRGW;;;S-1-5-…) — grant generic read+write to current user only.
  std::wstring sddl = L"D:(A;;GRGW;;;";
  sddl += pszSid;
  sddl += L")";
  LocalFree(pszSid);

  PSECURITY_DESCRIPTOR pSD = NULL;
  ConvertStringSecurityDescriptorToSecurityDescriptorW(
      sddl.c_str(), SDDL_REVISION_1, &pSD, NULL);
  return pSD;  // caller must LocalFree()
}

// Forward URI to first instance (pipe client)
void ForwardToFirstInstance(const wchar_t* uri) {
  HANDLE hPipe = CreateFileW(
      kRedirectPipeName, GENERIC_WRITE, 0, NULL, OPEN_EXISTING, 0, NULL);

  if (hPipe != INVALID_HANDLE_VALUE) {
    DWORD written = 0;
    size_t len = (wcslen(uri) + 1) * sizeof(wchar_t);
    WriteFile(hPipe, uri, (DWORD)len, &written, NULL);
    CloseHandle(hPipe);
  }
}

// Bring first instance window to foreground
void BringExistingWindowToFront() {
  HWND hwnd = FindWindowW(L"FLUTTER_RUNNER_WIN32_WINDOW", NULL);
  if (hwnd) {
    ShowWindow(hwnd, SW_RESTORE);
    SetForegroundWindow(hwnd);
  }
}

// Pipe server (runs in first instance)
void StartPipeServer() {
  std::thread([] {
    while (true) {
      // Restrict the pipe to the current user only.
      // A NULL security descriptor would allow any process on the system to
      // connect, which would let an attacker inject an arbitrary startup URL.
      PSECURITY_DESCRIPTOR pSD = BuildCurrentUserSD();
      if (!pSD) {
        // Cannot create a restricted descriptor; refuse to expose an
        // unrestricted pipe rather than fall back to the default DACL.
        return;
      }

      SECURITY_ATTRIBUTES sa = {};
      sa.nLength              = sizeof(sa);
      sa.lpSecurityDescriptor = pSD;
      sa.bInheritHandle       = FALSE;

      HANDLE hPipe = CreateNamedPipeW(
          kRedirectPipeName,
          PIPE_ACCESS_INBOUND,
          PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
          1, 0, 0, 0, &sa);

      // Security descriptor is no longer needed once the pipe is created.
      LocalFree(pSD);

      if (hPipe == INVALID_HANDLE_VALUE) {
        return;
      }

      if (ConnectNamedPipe(hPipe, NULL)) {
        wchar_t buffer[2048];
        DWORD read = 0;
        // Reserve one wchar_t for the null terminator so buffer[read/sizeof(wchar_t)]
        // is always within bounds (fixes the off-by-one overflow).
        if (ReadFile(hPipe, buffer, sizeof(buffer) - sizeof(wchar_t), &read, NULL)) {
          buffer[read / sizeof(wchar_t)] = L'\0';

          // Only accept URLs that begin with the expected auth0flutter:// prefix.
          // This is a defence-in-depth guard: even if an attacker managed to
          // connect to the pipe despite the restricted DACL, they cannot
          // overwrite PLUGIN_STARTUP_URL with an arbitrary string.
          size_t prefixLen = wcslen(kCallbackPrefix);
          if (wcslen(buffer) >= prefixLen &&
              wcsncmp(buffer, kCallbackPrefix, prefixLen) == 0) {
            SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", buffer);
            BringExistingWindowToFront();
          }
        }
      }
      DisconnectNamedPipe(hPipe);
      CloseHandle(hPipe);
    }
  }).detach();
}

int APIENTRY wWinMain(
    _In_ HINSTANCE instance,
    _In_opt_ HINSTANCE prev,
    _In_ wchar_t* /*command_line*/,
    _In_ int show_command) {

  if (!::AttachConsole(ATTACH_PARENT_PROCESS) && ::IsDebuggerPresent()) {
    CreateAndAttachConsole();
  }

  ::CoInitializeEx(nullptr, COINIT_APARTMENTTHREADED);

  // -----------------------------
  // Parse command line properly
  // -----------------------------
  int argc = 0;
  LPWSTR* argv = CommandLineToArgvW(GetCommandLineW(), &argc);

  std::wstring startupUri;
  if (argv && argc > 1) {
    // argv[1] is already de-quoted by Windows
    startupUri = argv[1];
  }

  if (argv) {
    LocalFree(argv);
  }

  // -----------------------------
  // Ensure single instance
  // -----------------------------
  bool hasUri = !startupUri.empty();

HANDLE hMutex = CreateMutexW(NULL, TRUE, kSingleInstanceMutex);
bool alreadyRunning = (hMutex && GetLastError() == ERROR_ALREADY_EXISTS);

if (alreadyRunning) {
  // Another instance is already running. Bring it to the foreground and exit,
  // regardless of whether this launch carried a protocol URI.
  BringExistingWindowToFront();
  if (hasUri) {
    ForwardToFirstInstance(startupUri.c_str());
  }
  return 0;
}

  // -----------------------------
  // First instance: store startup URI
  // -----------------------------
  // Apply the same prefix guard as the pipe server: only accept URIs that
  // begin with the expected auth0flutter:// scheme.  This ensures that an
  // unrelated protocol activation (e.g. a deep-link from a different app)
  // cannot overwrite PLUGIN_STARTUP_URL with arbitrary data.
  if (!startupUri.empty()) {
    size_t prefixLen = wcslen(kCallbackPrefix);
    bool isOurCallback = (startupUri.size() >= prefixLen &&
                          startupUri.compare(0, prefixLen, kCallbackPrefix) == 0);
    if (isOurCallback) {
      SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", startupUri.c_str());
    } else {
      SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
    }
  } else {
    SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", L"");
  }

  StartPipeServer();

  // -----------------------------
  // Flutter bootstrap
  // -----------------------------
  flutter::DartProject project(L"data");

  std::vector<std::string> command_line_arguments =
      GetCommandLineArguments();
  project.set_dart_entrypoint_arguments(std::move(command_line_arguments));

  FlutterWindow window(project);
  Win32Window::Point origin(10, 10);
  Win32Window::Size size(1280, 720);
  if (!window.Create(L"example", origin, size)) {
    return EXIT_FAILURE;
  }
  window.SetQuitOnClose(true);

  ::MSG msg;
  while (::GetMessage(&msg, nullptr, 0, 0)) {
    ::TranslateMessage(&msg);
    ::DispatchMessage(&msg);
  }

  ::CoUninitialize();
  return EXIT_SUCCESS;
}
