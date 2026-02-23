function update_libs
    set -l CACHE_DIR "$HOME/.cache/noon/build"
    set -l SOURCE_DIR "$HOME/.config/noon"

    rm -rf $CACHE_DIR
    mkdir -p $CACHE_DIR

    echo "==> Configuring Noon Library..."
    if cmake -S $SOURCE_DIR -B $CACHE_DIR -G Ninja -DCMAKE_BUILD_TYPE=Release
        echo "==> Building..."
        if cmake --build $CACHE_DIR
            echo "==> Installing to System..."
            sudo cmake --install $CACHE_DIR
            echo "==> Build successful."
        else
            echo "!! Build FAILED."
        end
    else
        echo "!! Configuration FAILED."
    end

    rm -rf $CACHE_DIR
    echo "==> Done. Build directory removed."
end
