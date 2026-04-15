#!/usr/bin/env bash
PLUGINS_DIR="${1:?Usage: plugins.sh <plugins_dir> <command>}"
CMD="${2:?Commands: list, enable, disable, install, remove}"
TARGET="$3"

list() {
    local first=1
    echo "{"
    for dir in "$PLUGINS_DIR"/*/; do
        local manifest="$dir/manifest.json"
        [[ -f "$manifest" ]] || continue
        local name absdir content
        name=$(jq -r '.name' "$manifest")
        absdir=$(realpath "$dir")
        content=$(sed "s|@plugins|$absdir|g" "$manifest" | jq '. + {isPlugin: true}')
        [[ $first -eq 1 ]] && first=0 || printf ",\n"
        printf "  \"%s\": %s" "$name" "$content"
    done
    printf "\n}\n"
}

_ensure_qml_setup() {
    local plugin_dir="$1"
    local manifest="$plugin_dir/manifest.json"

    [[ -f "$manifest" ]] || { echo "  [qml] no manifest at $manifest"; return; }

    local entry
    entry=$(jq -r '.entry // empty' "$manifest")
    [[ -n "$entry" ]] || { echo "  [qml] no entry field in manifest"; return; }

    local relative_entry
    relative_entry="${entry#@plugins/}"

    local entry_file="$plugin_dir/$relative_entry"
    [[ -f "$entry_file" ]] || { echo "  [qml] entry file not found: $entry_file"; return; }

    if ! grep -qF 'import "./"' "$entry_file"; then
        local tmp
        tmp=$(mktemp)
        { echo 'import "./"'; cat "$entry_file"; } > "$tmp" && mv "$tmp" "$entry_file"
        echo "  Injected 'import \"./\"' into $relative_entry"
    fi

   local qmldir="$plugin_dir/qmldir"
       if [[ ! -f "$qmldir" ]]; then
           local name version
           name=$(jq -r '.name' "$manifest")
           version=$(jq -r '.version // "1.0"' "$manifest")
           {
               printf 'module %s\n' "$name"
               while IFS= read -r qml; do
                   local component
                   component=$(basename "$qml" .qml)
                   printf '%s %s %s\n' "$component" "$version" "$(basename "$qml")"
               done < <(find "$plugin_dir" -maxdepth 1 -name "*.qml" | sort)
           } > "$qmldir"

           while IFS= read -r subdir; do
               local rel_sub sub_qmldir sub_module
               rel_sub="${subdir#$plugin_dir/}"
               sub_module="$name.$(echo "$rel_sub" | tr '/' '.')"
               sub_qmldir="$subdir/qmldir"
               [[ -f "$sub_qmldir" ]] && continue
               {
                   printf 'module %s\n' "$sub_module"
                   while IFS= read -r qml; do
                       local component
                       component=$(basename "$qml" .qml)
                       printf '%s %s %s\n' "$component" "$version" "$(basename "$qml")"
                   done < <(find "$subdir" -maxdepth 1 -name "*.qml" | sort)
               } > "$sub_qmldir"
               echo "  Created qmldir for submodule $sub_module"
           done < <(find "$plugin_dir" -mindepth 1 -type d | sort)

           echo "  Created qmldir for module $name"
       fi
}

enable() {
    local manifest="$PLUGINS_DIR/$TARGET/manifest.json"
    [[ -f "$manifest" ]] || { echo "Plugin '$TARGET' not found"; exit 1; }
    local tmp
    tmp=$(mktemp)
    jq '.enabled = true' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
    _ensure_qml_setup "$PLUGINS_DIR/$TARGET"
    echo "Enabled $TARGET"
}

disable() {
    local manifest="$PLUGINS_DIR/$TARGET/manifest.json"
    [[ -f "$manifest" ]] || { echo "Plugin '$TARGET' not found"; exit 1; }
    local tmp
    tmp=$(mktemp)
    jq '.enabled = false' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
    echo "Disabled $TARGET"
}

install() {
    [[ -e "$TARGET" ]] || { echo "Source '$TARGET' not found"; exit 1; }
    local name
    if [[ -d "$TARGET" ]]; then
        [[ -f "$TARGET/manifest.json" ]] || { echo "No manifest.json in '$TARGET'"; exit 1; }
        name=$(jq -r '.name' "$TARGET/manifest.json")
        cp -r "$TARGET" "$PLUGINS_DIR/$name"
    elif [[ "$TARGET" == *.tar.gz ]]; then
        local tmp
        tmp=$(mktemp -d)
        tar -xzf "$TARGET" -C "$tmp"
        local mf
        mf=$(find "$tmp" -maxdepth 2 -name manifest.json | head -1)
        [[ -f "$mf" ]] || { echo "No manifest.json in archive"; exit 1; }
        name=$(jq -r '.name' "$mf")
        cp -r "$(dirname "$mf")" "$PLUGINS_DIR/$name"
        rm -rf "$tmp"
    else
        echo "Unsupported format. Use a directory or .tar.gz"
        exit 1
    fi
    _ensure_qml_setup "$PLUGINS_DIR/$name"
    echo "Installed $name"
}

remove() {
    local dir="$PLUGINS_DIR/$TARGET"
    [[ -d "$dir" ]] || { echo "Plugin '$TARGET' not found"; exit 1; }
    rm -rf "$dir"
    echo "Removed $TARGET"
}

case "$CMD" in
    list)    list ;;
    enable)  enable ;;
    disable) disable ;;
    install) install ;;
    remove)  remove ;;
    *)       echo "Unknown command: $CMD"; exit 1 ;;
esac
