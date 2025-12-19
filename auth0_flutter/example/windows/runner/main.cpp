#include <flutter/dart_project.h>
#include <flutter/flutter_view_controller.h>
#include <windows.h>
#include <string>
#include <thread>

#include "flutter_window.h"
#include "utils.h"

const wchar_t* kSingleInstanceMutex = L"auth0flutter_single_instance_mutex";
const wchar_t* kRedirectPipeName    = L"\\\\.\\pipe\\auth0flutter_pipe";

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
      HANDLE hPipe = CreateNamedPipeW(
          kRedirectPipeName,
          PIPE_ACCESS_INBOUND,
          PIPE_TYPE_MESSAGE | PIPE_READMODE_MESSAGE | PIPE_WAIT,
          1, 0, 0, 0, NULL);

      if (hPipe == INVALID_HANDLE_VALUE) {
        return;
      }

      if (ConnectNamedPipe(hPipe, NULL)) {
        wchar_t buffer[2048];
        DWORD read = 0;
        if (ReadFile(hPipe, buffer, sizeof(buffer), &read, NULL)) {
          buffer[read / sizeof(wchar_t)] = L'\0';

          // Expose to plugin
          SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", buffer);

          // Bring app to front when redirect arrives
          BringExistingWindowToFront();
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
  HANDLE hMutex = CreateMutexW(NULL, TRUE, kSingleInstanceMutex);
  if (hMutex && GetLastError() == ERROR_ALREADY_EXISTS) {
    // Already running → forward URI (if present) and exit
    if (!startupUri.empty()) {
      ForwardToFirstInstance(startupUri.c_str());
    }
    return 0;
  }

  // -----------------------------
  // First instance: store startup URI
  // -----------------------------
  if (!startupUri.empty()) {
    SetEnvironmentVariableW(L"PLUGIN_STARTUP_URL", startupUri.c_str());
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
