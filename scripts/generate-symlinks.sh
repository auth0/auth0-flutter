#!/bin/sh

# This script generates symlinks for every file inside the 'darwin' directory
# of the auth0_flutter package, to the 'ios' and 'macos' directories.
# It's meant to be run from the repository root.

base_dir='auth0_flutter'
darwin_dir="auth0_flutter/darwin"
files=($(find "$darwin_dir" -type f -print))
repo_path=$(git rev-parse --show-toplevel)
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
            # If it's a .gitignore file, copy it
            (*'.gitignore') cp -v "$file" "$target_dir" ;;
            # Else symlink it
            (*) ln -sv "$repo_path/$file" "$target_file" ;;
        esac
    done
done

for platform in "${platforms[@]}"; do
    git add "$base_dir/$platform"
done
