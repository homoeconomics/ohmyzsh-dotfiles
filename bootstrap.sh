#!/usr/bin/env bash
#
# Bootstrap script to create symbolic links from dotfiles to the home directory
# This script symlinks .mix-*, .zshrc, and .git* files to the home directory

# Set the source directory (current directory) and target directory (home directory)
DOTFILES_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
TARGET_DIR="$HOME"

echo "Creating symbolic links from $DOTFILES_DIR to $TARGET_DIR"

# Function to create a symbolic link
create_symlink() {
    local source_file="$1"
    local target_file="$2"

    # Check if the target file already exists
    if [ -e "$target_file" ]; then
        # If it's already a symlink to our file, do nothing
        if [ -L "$target_file" ] && [ "$(readlink "$target_file")" = "$source_file" ]; then
            echo "Link already exists: $target_file -> $source_file"
            return
        fi

        # Backup the existing file
        echo "Backing up existing file: $target_file -> $target_file.backup"
        mv "$target_file" "$target_file.backup"
    fi

    # Create the symbolic link
    echo "Creating link: $target_file -> $source_file"
    ln -s "$source_file" "$target_file"
}

# Symlink .mix-* files
for file in "$DOTFILES_DIR"/.mix-*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$TARGET_DIR/$filename"
    fi
done

# Symlink .zshrc file
if [ -f "$DOTFILES_DIR/.zshrc" ]; then
    create_symlink "$DOTFILES_DIR/.zshrc" "$TARGET_DIR/.zshrc"
fi

# Symlink .git* files
for file in "$DOTFILES_DIR"/.git*; do
    if [ -f "$file" ]; then
        filename=$(basename "$file")
        create_symlink "$file" "$TARGET_DIR/$filename"
    fi
done

echo "Symlinking complete!"

# Clone and setup tmux configuration
echo "Setting up tmux configuration..."

# Check if .tmux directory already exists
if [ -d "$TARGET_DIR/.tmux" ]; then
    echo ".tmux directory already exists, skipping clone"
else
    echo "Cloning tmux configuration from GitHub..."
    cd "$TARGET_DIR"
    git clone --single-branch https://github.com/gpakosz/.tmux.git
fi

# Create symbolic link for .tmux.conf
create_symlink "$TARGET_DIR/.tmux/.tmux.conf" "$TARGET_DIR/.tmux.conf"

# Copy .tmux.conf.local if it doesn't exist
if [ ! -f "$TARGET_DIR/.tmux.conf.local" ]; then
    echo "Copying .tmux.conf.local to $TARGET_DIR"
    cp "$TARGET_DIR/.tmux/.tmux.conf.local" "$TARGET_DIR/"
else
    echo ".tmux.conf.local already exists, skipping copy"
fi

echo "tmux configuration setup complete!"
