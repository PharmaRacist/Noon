#!/bin/bash

# Set the source directory for the images
SOURCE_DIR="$HOME/Pictures/Memories"

# Set the target directory for the symlink
TARGET_DIR="$HOME/Pictures/"

# Create the target directory if it doesn't exist
mkdir -p "$TARGET_DIR"

# Infinite loop to keep the script running
while true; do
  # Remove any existing symlink or file named gallery.* in the target directory
  rm -f "$TARGET_DIR/gallery"* 

  # Find all image files (extensions .jpg, .jpeg, .png, .gif) in the source directory and subdirectories
  IMAGE_FILES=($(find "$SOURCE_DIR" -type f \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.gif" \)))

  # Check if there are any image files found
  if [ ${#IMAGE_FILES[@]} -gt 0 ]; then
    # Select a random image file from the array
    RANDOM_IMAGE="${IMAGE_FILES[$RANDOM % ${#IMAGE_FILES[@]}]}"

    # Extract the file name (without path)
    IMAGE_NAME=$(basename "$RANDOM_IMAGE")

    # Extract the file extension after the last dot (handling spaces in filenames)
    EXTENSION="${IMAGE_NAME##*.}"

    # Set the symlink name to "gallery" with the original extension
    SYMLINK_NAME="gallery.$EXTENSION"

    # Create the symlink in the target directory
    ln -sf "$RANDOM_IMAGE" "$TARGET_DIR/$SYMLINK_NAME"

    echo "Symlink updated: $TARGET_DIR/$SYMLINK_NAME -> $RANDOM_IMAGE"
  else
    echo "No image files found in $SOURCE_DIR."
  fi

  # Wait for 5 minutes (300 seconds) before running again
  sleep 300
done

