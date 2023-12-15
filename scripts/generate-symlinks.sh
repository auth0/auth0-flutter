#!/bin/bash

# This script generates symlinks for every file inside the 'darwin' directory
# of the auth0_flutter package, to the 'ios' and 'macos' directories.
# It's meant to be run from the repository root.

set -euo pipefail

repo_path=$(git rev-parse --show-toplevel)

if [ "$repo_path" != $PWD ]; then
    echo 'This script must be run from the repository root'
    exit 1
fi

base_dir='auth0_flutter'
darwin_dir='auth0_flutter/darwin'
files=($(find "$darwin_dir" -type f -print))
platforms=('ios' 'macos')

for platform in "${platforms[@]}"; do
    rm -rf "$base_dir/$platform"
done

for file in "${files[@]}"; do
    for platform in "${platforms[@]}"; do
        target_file=$(echo "$file" | sed "s/darwin/$platform/")
        target_dir=$(dirname "$target_file")

        mkdir -p "$target_dir"

        case "$file" in
            # If it's a .gitignore or Podspec file, copy it
            (*'.gitignore' | *'.podspec') cp -v "$file" "$target_dir" ;;
            # Else symlink it
            (*)
                # Calculate the relative path to the file from the symlink's
                # location
                file_subpath=${file#"$base_dir/"}
                file_depth=$(echo "$file_subpath" | awk -F '/' '{print NF-1}')
                file_relpath=$(printf '../%.0s' $(seq 1 $file_depth))

                ln -sv "$file_relpath$file_subpath" "$target_file" ;;
        esac
    done
done

for platform in "${platforms[@]}"; do
    git add "$base_dir/$platform"
done
