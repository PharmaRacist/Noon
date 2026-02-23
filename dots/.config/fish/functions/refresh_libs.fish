function update_libs
    set -l CACHE_DIR "$HOME/.cache/noon/build"
    set -l SOURCE_DIR "$HOME/.config/noon"

    # 1. Don't remove the directory. Just ensure it exists.
    if not test -d $CACHE_DIR
        mkdir -p $CACHE_DIR
    end

    echo "==> Configuring Noon Library..."
    # 2. Re-running cmake is fast if the cache exists. 
    # Ninja will notice if no CMake files changed and skip the heavy lifting.
    if cmake -S $SOURCE_DIR -B $CACHE_DIR -G Ninja -DCMAKE_BUILD_TYPE=Release
        echo "==> Building (Incremental)..."
        
        # 3. Only build the specific target you're working on to save even more time
        # You can pass an argument to this function, e.g., 'update_libs noon_utils_qr'
        if test -n "$argv[1]"
            cmake --build $CACHE_DIR --target $argv[1]
        else
            cmake --build $CACHE_DIR
        end

        if test $status -eq 0
            echo "==> Installing..."
            sudo cmake --install $CACHE_DIR
            echo "==> Success."
        else
            echo "!! Build FAILED."
        end
    else
        echo "!! Configuration FAILED."
    end

    # 4. CRITICAL: Never remove the CACHE_DIR if you want speed!
    echo "==> Done. Cache preserved for next build."
end
