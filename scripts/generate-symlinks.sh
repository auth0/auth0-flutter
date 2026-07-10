#!/bin/bash

# Generates symlinks so that CocoaPods consumers (ios/ and macos/) stay in
# sync with the canonical source tree under darwin/auth0_flutter/Sources/.
#
# Layout produced:
#   darwin/Classes/<rel>         -> ../../auth0_flutter/Sources/auth0_flutter/<rel>
#   ios/Classes/<rel>            -> ../../../darwin/Classes/<rel>
#   macos/Classes/<rel>          -> ../../../darwin/Classes/<rel>
#
# Run from the repository root.

set -euo pipefail

repo_path=$(git rev-parse --show-toplevel)

if [ "$repo_path" != "$PWD" ]; then
    echo 'This script must be run from the repository root'
    exit 1
fi

base_dir='auth0_flutter'
sources_dir='auth0_flutter/darwin/auth0_flutter/Sources/auth0_flutter'
darwin_classes_dir='auth0_flutter/darwin/Classes'

# Collect all real Swift/ObjC source files under Sources/auth0_flutter.
# Portable: bash 3.2 (macOS) does not have mapfile; use a while-read loop instead.
files=()
while IFS= read -r file; do
    files+=("$file")
done < <(find "$sources_dir" -type f \( -name '*.swift' -o -name '*.h' -o -name '*.m' \))

if [ ${#files[@]} -eq 0 ]; then
    echo "No source files found under $sources_dir"
    exit 1
fi

# Rebuild darwin/Classes symlinks -> Sources
rm -rf "$darwin_classes_dir"

for file in "${files[@]}"; do
    # rel path relative to sources_dir, e.g. AuthAPI/AuthAPIExtensions.swift
    rel=${file#"$sources_dir/"}

    darwin_link="$darwin_classes_dir/$rel"
    darwin_link_dir=$(dirname "$darwin_link")
    mkdir -p "$darwin_link_dir"

    # Depth of rel's subdirectories (e.g. AuthAPI/X.swift -> 1), plus 1 to
    # step out of darwin/Classes/ itself and into darwin/.
    rel_depth=$(echo "$rel" | awk -F '/' '{print NF-1}')
    link_depth=$((rel_depth + 1))
    up=$(printf '../%.0s' $(seq 1 "$link_depth"))
    ln -sf "${up}auth0_flutter/Sources/auth0_flutter/$rel" "$darwin_link"
done

# Rebuild ios/Classes and macos/Classes symlinks -> darwin/Classes
for platform in ios macos; do
    platform_classes_dir="$base_dir/$platform/Classes"
    rm -rf "$platform_classes_dir"

    for file in "${files[@]}"; do
        rel=${file#"$sources_dir/"}

        platform_link="$platform_classes_dir/$rel"
        platform_link_dir=$(dirname "$platform_link")
        mkdir -p "$platform_link_dir"

        # Depth of rel's subdirectories, plus 1 to step out of
        # <platform>/Classes/ itself and into <platform>/.
        rel_depth=$(echo "$rel" | awk -F '/' '{print NF-1}')
        link_depth=$((rel_depth + 1))
        up=$(printf '../%.0s' $(seq 1 "$link_depth"))
        ln -sf "${up}../darwin/Classes/$rel" "$platform_link"
    done

    git add "$base_dir/$platform"
done

git add "$darwin_classes_dir"

# Verify every symlink we just created actually resolves.
dangling=0
while IFS= read -r link; do
    if [ ! -e "$link" ]; then
        echo "::error::Dangling symlink: $link -> $(readlink "$link")"
        dangling=1
    fi
done < <(find "$darwin_classes_dir" "$base_dir/ios/Classes" "$base_dir/macos/Classes" -type l)

if [ "$dangling" -ne 0 ]; then
    echo "One or more symlinks are dangling. See errors above."
    exit 1
fi

echo "Symlinks regenerated successfully."
