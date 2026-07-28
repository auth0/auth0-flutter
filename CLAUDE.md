# Auth0 Flutter SDK - AI Agent Guidelines

This document provides guidelines for AI agents (like Claude) working on the Auth0 Flutter SDK.

## Project Overview

This is a Flutter plugin that provides Auth0 authentication for Flutter applications across multiple platforms:
- **Android**: Native Kotlin implementation using Auth0.Android SDK
- **iOS/macOS/tvOS/watchOS**: Native Swift implementation using Auth0.swift SDK  
- **Web**: Dart implementation using auth0-spa-js

The project structure:
- `/auth0_flutter`: Main plugin package with platform channels
- `/auth0_flutter_platform_interface`: Platform interface defining the contract
- `/auth0_flutter/example`: Example Flutter app for testing
- `/auth0_flutter/darwin/auth0_flutter`: Swift implementation for Apple platforms

## Development Workflow

### Branch Naming Conventions

When creating branches, follow these patterns:
- `feat/<feature-name>`: New features (e.g., `feat/passkey-support`)
- `fix/<issue-description>`: Bug fixes (e.g., `fix/credentials-memory-leak`)
- `chore/<task>`: Maintenance tasks (e.g., `chore/update-dependencies`)
- `docs/<update>`: Documentation updates (e.g., `docs/quickstart-guide`)

### Making Changes

#### 1. Create a Feature Branch

```bash
# Create and checkout a new branch from the appropriate base branch
git checkout -b <branch-type>/<descriptive-name> <base-branch>
```

For major version migrations, check if there's a dedicated base branch (e.g., `develop/v3.0` for Auth0.swift v3 migration).

#### 2. Make and Test Changes

- **Android changes**: Modify Kotlin files in `auth0_flutter/android/`
- **iOS/macOS changes**: Modify Swift files in `auth0_flutter/darwin/auth0_flutter/`
- **Dart changes**: Modify files in `auth0_flutter/lib/`
- **Tests**: Update corresponding test files in platform-specific test directories

**Always run tests before committing:**
```bash
# Dart/Flutter tests
cd auth0_flutter && flutter test

# iOS unit tests
cd auth0_flutter/example/ios
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=iOS Simulator,name=iPhone 15'

# macOS unit tests  
cd auth0_flutter/example/macos
xcodebuild test -workspace Runner.xcworkspace -scheme Runner -destination 'platform=macOS'

# Android unit tests
cd auth0_flutter/example/android
./gradlew test
```

#### 3. Commit Changes

Follow conventional commit format:

```bash
git add <files>
git commit -m "<type>: <description>

<optional body explaining the changes>

<optional footer with breaking changes, issue references>"
```

**Commit types:**
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `test`: Test additions/modifications
- `refactor`: Code refactoring
- `chore`: Maintenance tasks
- `perf`: Performance improvements

**Example:**
```bash
git commit -m "feat: upgrade Auth0.swift to v3.0.1

- Updated podspec and SPM dependencies to Auth0.swift 3.0.1
- Migrated from .webAuthError() to .authenticationError()
- Updated credentials manager API signatures
- Fixed all unit tests for new SDK version

BREAKING CHANGE: Requires Auth0.swift 3.0.1 or higher"
```

#### 4. Push Changes

```bash
# Push to remote and set upstream tracking
git push -u origin <branch-name>
```

#### 5. Create a Pull Request

Use the GitHub CLI (`gh`) to create a draft PR:

```bash
gh pr create \
  --draft \
  --base <target-branch> \
  --title "<type>: <concise-title>" \
  --body "$(cat <<'EOF'
## Summary
- Key change 1
- Key change 2
- Key change 3

## Detailed Changes
### Component 1
Description of changes...

### Component 2
Description of changes...

## Breaking Changes
- List any breaking changes
- Explain migration path

## Test Plan
- [ ] Unit tests pass (Dart)
- [ ] iOS unit tests pass
- [ ] macOS unit tests pass
- [ ] Android unit tests pass
- [ ] Integration tests pass
- [ ] Manual testing completed

## Checklist
- [ ] Code follows project conventions
- [ ] Tests added/updated
- [ ] Documentation updated
- [ ] CHANGELOG.md updated (if applicable)
- [ ] No breaking changes (or clearly documented)
EOF
)"
```

**For GitHub Actions MCP (if available):**
```bash
# Authenticate first (if not already authenticated)
gh auth status || gh auth login

# Create PR using GitHub CLI
gh pr create --draft --base develop/v3.0 --title "feat: upgrade Auth0.swift to v3.0.1" --body "<markdown-body>"
```

### Multi-Project Changes

When changes span both iOS and macOS (sharing Darwin implementation):

1. **iOS changes** in `auth0_flutter/example/ios/Tests/` are typically shared with macOS
2. **Check both platforms**: Ensure test files are added to both Xcode projects if they reference shared code
3. **Verify project files**: Both `ios/Runner.xcodeproj/project.pbxproj` and `macos/Runner.xcodeproj/project.pbxproj` may need updates

## Platform-Specific Guidelines

### Darwin (iOS/macOS/tvOS/watchOS)

**Key Files:**
- `auth0_flutter/darwin/auth0_flutter/Package.swift`: SPM manifest
- `auth0_flutter/ios/auth0_flutter.podspec`: iOS CocoaPods spec  
- `auth0_flutter/macos/auth0_flutter.podspec`: macOS CocoaPods spec
- Platform implementation: `auth0_flutter/darwin/auth0_flutter/Sources/`

**Test Structure:**
- Shared tests: `auth0_flutter/example/ios/Tests/` (referenced by both iOS and macOS)
- Both Xcode projects must include test files in their respective targets
- Use the `xcodeproj` Ruby gem to programmatically modify project files if needed

**Common Issues:**
- Missing test files in macOS project when they exist in iOS
- Swift version mismatches between example app and plugin
- Podfile dependency version conflicts

### Android

**Key Files:**
- `auth0_flutter/android/build.gradle`: Android plugin build config
- `auth0_flutter/android/src/main/kotlin/`: Kotlin implementation
- `auth0_flutter/android/src/test/`: Android unit tests

**Test Structure:**
- Unit tests: `src/test/kotlin/`
- Integration tests: `example/android/app/src/androidTest/`

### Web

**Key Files:**
- `auth0_flutter/lib/src/web/`: Web implementation using auth0-spa-js
- Tests use standard Flutter test infrastructure

## Common Workflows

### Updating Native SDK Versions

When updating Auth0.swift or Auth0.Android:

1. Update dependency declarations:
   - For iOS/macOS: Update podspec files and Package.swift
   - For Android: Update build.gradle dependencies
2. Check migration guides for breaking changes
3. Update method handlers for API changes
4. Update test mocks/spies to match new signatures
5. Run full test suite on all platforms
6. Update example app dependencies
7. Test example app manually

### Adding New Features

1. Update platform interface: `auth0_flutter_platform_interface/lib/`
2. Implement in each platform:
   - Darwin: Add method handler in `Sources/auth0_flutter/`
   - Android: Add method handler in `src/main/kotlin/`
   - Web: Add implementation in `lib/src/web/`
3. Add Dart API in `auth0_flutter/lib/src/`
4. Write tests for all platforms
5. Update example app to demonstrate feature
6. Document in README and API docs

## Git and CI/CD

### Branch Protection

- `main`: Protected, requires PR reviews and passing CI
- Release branches: Protected, version tags trigger releases
- Development branches: May have dedicated base branches for major work

### CI Checks

The project runs GitHub Actions for:
- Flutter analyze and format checks
- Unit tests (Dart, iOS, macOS, Android)
- Integration tests
- Build verification

**Common CI Failures:**
- Code not formatted: Run `dart format .`
- Analyzer warnings: Fix or suppress with `// ignore:` comments
- Missing test files in platform projects
- SDK version mismatches

### Pre-commit Hooks

Configure git hooks:
```bash
git config core.hooksPath .githooks
```

## AI Agent Specific Instructions

### When Asked to Create a PR

1. **Check for existing branch**: Verify if you're on the right branch or need to create one
2. **Verify base branch**: For major upgrades, check if there's a dedicated base branch (e.g., `develop/v3.0`)
3. **Run tests**: Always verify tests pass before pushing
4. **Create descriptive commit**: Use conventional commits with detailed body
5. **Push with upstream**: Use `git push -u origin <branch>`
6. **Create draft PR**: Use `gh pr create --draft --base <base-branch>` with detailed body
7. **Return PR URL**: Always provide the PR URL to the user

### When Making Platform-Specific Changes

1. **iOS/macOS changes**: Check if both Xcode projects need file additions
2. **Shared test files**: iOS and macOS share tests via relative paths (`../ios/Tests/`)
3. **Version alignment**: Keep Auth0.swift version consistent across iOS/macOS podspecs
4. **Test targets**: Verify files are in correct test targets (RunnerTests, UITests)

### Using Ruby xcodeproj Gem

When adding files to Xcode projects programmatically:

```ruby
require 'xcodeproj'

project_path = '/path/to/Runner.xcodeproj'
project = Xcodeproj::Project.open(project_path)

# Find target
target = project.targets.find { |t| t.name == 'RunnerTests' }

# Create/find group
group = project.main_group.find_subpath('Tests/Mfa', true)

# Add files
files = ['File1.swift', 'File2.swift']
files.each do |filename|
  file_ref = group.new_file("../ios/Tests/Mfa/#{filename}")
  target.add_file_references([file_ref])
end

project.save
```

### Debugging Test Failures

1. **"Cannot find type" errors**: Missing test file in target
2. **"No such module"**: Dependency not linked or version mismatch  
3. **SDK signature errors**: Native SDK version changed, update mocks
4. **Deployment target errors**: May indicate Xcode beta incompatibility

## Resources

- [Auth0.swift Migration Guides](https://github.com/auth0/Auth0.swift/blob/main/MIGRATION_GUIDE.md)
- [Auth0.Android Migration Guides](https://github.com/auth0/Auth0.Android#migration-guides)
- [Flutter Plugin Development](https://docs.flutter.dev/development/packages-and-plugins/developing-packages)
- [Conventional Commits](https://www.conventionalcommits.org/)

## Support

- GitHub Issues: https://github.com/auth0/auth0-flutter/issues
- Auth0 Community: https://community.auth0.com/
