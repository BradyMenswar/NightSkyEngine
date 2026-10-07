#!/bin/bash
# Build and launch with the installed UE 5.7 toolchain.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ENGINE="${UE_ROOT:-/Users/Shared/Epic Games/UE_5.7}"
PROJECT="$ROOT/NightSkyEngine.uproject"
ACTION="${1:-build}"
if [[ $# -gt 0 ]]; then shift; fi

if [[ "$(uname -s)" != Darwin ]]; then
    echo "This script requires macOS." >&2
    exit 1
fi

# Prefer the side-by-side UE-compatible toolchain, without changing xcode-select.
# An explicit DEVELOPER_DIR always takes precedence.
if [[ -z "${DEVELOPER_DIR:-}" && -d /Applications/Xcode_26.app/Contents/Developer ]]; then
    export DEVELOPER_DIR=/Applications/Xcode_26.app/Contents/Developer
fi

build() {
    local build_script="$ENGINE/Engine/Build/BatchFiles/Mac/Build.sh"
    if [[ ! -f "$build_script" ]]; then
        echo "UE 5.7 not found at $ENGINE. Set UE_ROOT to its installation directory." >&2
        exit 1
    fi
    /bin/bash "$build_script" NightSkyEngineEditor Mac Development "$PROJECT" -WaitMutex "$@"
}

case "$ACTION" in
    build) build "$@" ;;
    run)
        build
        editor="$ENGINE/Engine/Binaries/Mac/UnrealEditor.app/Contents/MacOS/UnrealEditor"
        if [[ ! -x "$editor" ]]; then
            echo "Unreal Editor executable not found: $editor" >&2
            exit 1
        fi
        exec "$editor" "$PROJECT" "$@"
        ;;
    *) echo "Usage: $0 [build|run] [Unreal arguments...]" >&2; exit 2 ;;
esac
