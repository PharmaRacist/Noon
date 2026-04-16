#!/usr/bin/env bash

PLUGINS_DIR="$HOME/.noon_plugins"

CMD="${1:?Usage: $(basename "$0") <command> [group] [target] [-f]}"
GROUP="$2"
TARGET="$3"
FORCE=0
[[ "$3" == "-f" || "$4" == "-f" ]] && FORCE=1
[[ "$3" == "-f" ]] && TARGET=""

_plugin_dir() {
    echo "$PLUGINS_DIR/$GROUP/$TARGET"
}

list() {
    local first=1
    echo "{"
    for dir in "$PLUGINS_DIR/$GROUP"/*/; do
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

_write_qmldir() {
    local dir="$1"
    local module="$2"
    local out="$dir/qmldir"
    [[ -f "$out" && "$FORCE" -eq 0 ]] && return

    {
        printf 'module %s\n' "$module"
        while IFS= read -r qml; do
            local component basename_qml is_singleton
            basename_qml=$(basename "$qml")
            component=$(basename "$qml" .qml)
            is_singleton=$(echo "$singletons_json" | jq -r --arg f "$basename_qml" 'if . | contains([$f]) then "1" else "0" end')
            if [[ "$is_singleton" == "1" ]]; then
                printf 'singleton %s %s %s\n' "$component" "$version" "$basename_qml"
            else
                printf '%s %s %s\n' "$component" "$version" "$basename_qml"
            fi
        done < <(find "$dir" -maxdepth 1 -name "*.qml" | sort)
    } > "$out"

    echo "  Created qmldir for module $module"
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

    local name version singletons_json
    name=$(jq -r '.name' "$manifest")
    version=$(jq -r '.version // "1.0"' "$manifest")
    singletons_json=$(jq -r '[.singletons // [] | .[] ] | @json' "$manifest")

    if [[ ! -f "$plugin_dir/qmldir" || "$FORCE" -eq 1 ]]; then
        _write_qmldir "$plugin_dir" "$name"

        while IFS= read -r subdir; do
            local rel_sub sub_module
            rel_sub="${subdir#$plugin_dir/}"
            sub_module="$name.$(echo "$rel_sub" | tr '/' '.')"
            _write_qmldir "$subdir" "$sub_module"
        done < <(find "$plugin_dir" -mindepth 1 -type d | sort)
    fi
}

enable() {
    local plugin_dir
    plugin_dir=$(_plugin_dir)
    local manifest="$plugin_dir/manifest.json"
    [[ -f "$manifest" ]] || { echo "Plugin '$GROUP/$TARGET' not found"; exit 1; }
    local tmp
    tmp=$(mktemp)
    jq '.enabled = true' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
    _ensure_qml_setup "$plugin_dir"
    echo "Enabled $GROUP/$TARGET"
}

disable() {
    local plugin_dir
    plugin_dir=$(_plugin_dir)
    local manifest="$plugin_dir/manifest.json"
    [[ -f "$manifest" ]] || { echo "Plugin '$GROUP/$TARGET' not found"; exit 1; }
    local tmp
    tmp=$(mktemp)
    jq '.enabled = false' "$manifest" > "$tmp" && mv "$tmp" "$manifest"
    echo "Disabled $GROUP/$TARGET"
}

install() {
    [[ -n "$GROUP" ]] || { echo "Group required: $(basename "$0") install <group> <source>"; exit 1; }
    [[ -e "$TARGET" ]] || { echo "Source '$TARGET' not found"; exit 1; }
    local name
    if [[ -d "$TARGET" ]]; then
        [[ -f "$TARGET/manifest.json" ]] || { echo "No manifest.json in '$TARGET'"; exit 1; }
        name=$(jq -r '.name' "$TARGET/manifest.json")
        cp -r "$TARGET" "$PLUGINS_DIR/$GROUP/$name"
    elif [[ "$TARGET" == *.tar.gz ]]; then
        local tmp
        tmp=$(mktemp -d)
        tar -xzf "$TARGET" -C "$tmp"
        local mf
        mf=$(find "$tmp" -maxdepth 2 -name manifest.json | head -1)
        [[ -f "$mf" ]] || { echo "No manifest.json in archive"; exit 1; }
        name=$(jq -r '.name' "$mf")
        cp -r "$(dirname "$mf")" "$PLUGINS_DIR/$GROUP/$name"
        rm -rf "$tmp"
    else
        echo "Unsupported format. Use a directory or .tar.gz"
        exit 1
    fi
    _ensure_qml_setup "$PLUGINS_DIR/$GROUP/$name"
    echo "Installed $GROUP/$name"
}

remove() {
    local plugin_dir
    plugin_dir=$(_plugin_dir)
    [[ -d "$plugin_dir" ]] || { echo "Plugin '$GROUP/$TARGET' not found"; exit 1; }
    rm -rf "$plugin_dir"
    echo "Removed $GROUP/$TARGET"
}

case "$CMD" in
    list)    list ;;
    enable)  enable ;;
    disable) disable ;;
    install) install ;;
    remove)  remove ;;
    *)       echo "Unknown command: $CMD"; exit 1 ;;
esac
