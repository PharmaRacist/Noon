#!/bin/bash

# Use kdialog to select an image file
selected_file=$(kdialog --getopenfilename "$HOME" "Image Files (*.png *.jpg *.jpeg *.gif *.bmp *.svg)|All Files (*)")

# Check if user cancelled
if [ -z "$selected_file" ]; then
    kdialog --error "No file selected. Exiting."
    exit 1
fi

# Check if file exists
if [ ! -f "$selected_file" ]; then
    kdialog --error "Selected file does not exist: $selected_file"
    exit 1
fi

# Target symlink path
face_path="$HOME/.face.icon"

# Remove existing symlink/file
if [ -e "$face_path" ] || [ -L "$face_path" ]; then
    rm "$face_path"
fi

# Create symlink
ln -sf "$selected_file" "$HOME/.face.icon"
ln -sf "$selected_file" "$HOME/.face"

# Verify success
if [ -L "$face_path" ]; then
    kdialog --msgbox "Face icon set successfully!\n\nLinked: $selected_file\nTo: $face_path"
else
    kdialog --error "Failed to create symlink."
    exit 1
fi
