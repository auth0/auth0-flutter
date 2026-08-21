#!/bin/bash

# Syncs the Auth0 native dependency versions declared in the CocoaPods podspecs
# (ios/, macos/, darwin/) with the canonical versions pinned in the Swift Package
# Manager manifest under darwin/auth0_flutter/Package.swift.
#
# Package.swift is the single source of truth: Dependabot (swift ecosystem) bumps
# it, and this script propagates the new version into the podspecs, which
# CocoaPods consumers rely on.
#
# Run from the repository root.

set -euo pipefail

repo_path=$(git rev-parse --show-toplevel)

if [ "$repo_path" != "$PWD" ]; then
    echo 'This script must be run from the repository root'
    exit 1
fi

package_swift='auth0_flutter/darwin/auth0_flutter/Package.swift'

podspecs=(
    'auth0_flutter/ios/auth0_flutter.podspec'
    'auth0_flutter/macos/auth0_flutter.podspec'
    'auth0_flutter/darwin/auth0_flutter.podspec'
)

# Maps the CocoaPods pod name (as it appears in `s.dependency '<pod>', '<ver>'`)
# to the trailing path of its Swift package URL in Package.swift
# (`.package(url: "https://github.com/auth0/<url>", exact: "<ver>")`).
pods=('Auth0' 'JWTDecode' 'SimpleKeychain')
urls=('Auth0.swift' 'JWTDecode.swift' 'SimpleKeychain')

for i in "${!pods[@]}"; do
    pod="${pods[$i]}"
    url="${urls[$i]}"

    # Extract the version pinned for this package in Package.swift. Match the
    # exact URL (including the closing quote) so e.g. Auth0.swift does not also
    # match a longer URL, then pull out the semantic version.
    line=$(grep -F "github.com/auth0/${url}\"" "$package_swift" || true)
    version=$(printf '%s\n' "$line" | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -1 || true)

    if [ -z "$version" ]; then
        echo "::error::Could not find a version for '$url' in $package_swift"
        exit 1
    fi

    for spec in "${podspecs[@]}"; do
        # Portable in-place edit: perl is available on both macOS and the CI
        # runners, and \x27 lets us match the literal single quotes in the
        # podspec without shell-quoting gymnastics.
        POD="$pod" VER="$version" perl -i -pe \
            's/(s\.dependency\s+\x27\Q$ENV{POD}\E\x27\s*,\s*\x27)\d+\.\d+\.\d+(\x27)/$1$ENV{VER}$2/' \
            "$spec"
    done
done

for spec in "${podspecs[@]}"; do
    git add "$spec"
done

echo 'Podspec dependency versions synced with Package.swift.'
