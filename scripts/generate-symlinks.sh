#!/bin/sh

# This script generates symlinks for every file inside the 'darwin' directory
# of the auth0_flutter package, to the 'ios' and 'macos' directories.

# First argument is the root directory of the auth0_flutter package
if [ -z "$1" ]; then
    echo 'Missing base directory'
    exit 0
fi

# Second argument is the 'darwin' directory inside the auth0_flutter
# package
if [ -z "$2" ]; then
    echo "Missing 'darwin' directory"
    exit 0
fi

base_dir="$1"
darwin_dir="$2"
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
