# Building and running on macOS

## Prerequisites

- Unreal Engine **5.7**, including Mac platform support, installed through Epic Games Launcher or built from source.
- Full Xcode, its command-line tools, and the Metal toolchain required by Unreal. Open Xcode once to finish installing components and accept its license.
- An Xcode version accepted by your UE installation. The tested installation's `Engine/Config/Apple/Apple_SDK.json` accepts **15.2–26.9**; Xcode **27.0 is rejected** before compilation. Use a supported Xcode release (e.g. 26.x), rather than editing Unreal's SDK limits. The accepted version range is not a guarantee that every listed version supports your current macOS/hardware.
- A Mac meeting UE 5.7's hardware and macOS requirements. This is the high-end branch; graphics features and performance vary by GPU. Use the `lowend` branch if necessary.

## Build and open the editor

From the repository root:

```bash
bash Scripts/mac.sh build
bash Scripts/mac.sh run
```

The script defaults to `/Users/Shared/Epic Games/UE_5.7` and automatically selects `/Applications/Xcode_26.app` when present. It does not change the system-wide `xcode-select` setting. Override the installation path and, optionally, select another Xcode for this process only:

```bash
DEVELOPER_DIR=/Applications/Xcode_26.app/Contents/Developer \
UE_ROOT=/path/to/UE_5.7 bash Scripts/mac.sh run
```

`run` builds the editor target first and launches the project only if the build succeeds. In Unreal, use Play to test the startup test map, or open `Content/NightSkyEngine/Maps/MainMenu_PL` to test the menu flow. For standalone play through the project's default game map:

```bash
bash Scripts/mac.sh run -game -log
```

This compiles the editor target, not a cooked/distributable game. Package for Mac through Unreal's Platforms menu after editor play works.

The existing project uses Steam (development App ID 480). Steam online play requires the Steam client and a valid login. For local testing without Steam, pass `-nosteam` to the editor; Steam matchmaking is not validated by the backend smoke test below.

## Troubleshooting

If Unreal reports `Platform Mac is not a valid platform to build`, check the UnrealBuildTool log under `~/Library/Application Support/Epic/UnrealBuildTool/Log.txt`. In particular, `Found Sdk Version=27.0, ... MaxRequired=26.9.0` means the active Xcode is too new. Check `xcodebuild -version` and `xcode-select -p`, or use `DEVELOPER_DIR` as above. Also check that Mac support is installed for Unreal.

If Metal shader compilation reports a missing Metal toolchain, install and verify it:

```bash
DEVELOPER_DIR=/Applications/Xcode_26.app/Contents/Developer \
xcodebuild -downloadComponent MetalToolchain
DEVELOPER_DIR=/Applications/Xcode_26.app/Contents/Developer \
xcrun metal --version
```

## Standalone GGPO backend test

This exercises the Mac/POSIX timer and event implementation without Unreal:

```bash
GGPO=Plugins/NightSkyEngine/Source/GGPOUE4/Private
clang++ -std=c++17 -pthread -I"$GGPO" Tests/GGPOPlatformSmoke.cpp \
  "$GGPO/platform_unix.cpp" "$GGPO/pevents.cpp" -o /tmp/nightsky-ggpo-smoke
/tmp/nightsky-ggpo-smoke
```

The portability changes enable GGPO's existing POSIX backend on Apple platforms and make local header lookup explicit. NightSkyEngine's gameplay networking uses its own connection manager; the legacy `UDPConnectionManager` remains Windows-only.

## Validation status

The UE 5.7 Mac editor target compiles and links successfully on Apple Silicon with Xcode 26.6. After installing the Metal toolchain, the editor initializes with Metal and loads the startup test map. The standalone GGPO test also passes, including with Apple's `FALSE` macro already defined. Xcode 27.0 was rejected by Unreal's SDK validation.

Startup logs report uninitialized reflected struct properties and a missing `TestMap_PL_BuiltData` package; these are separate project cleanup items, not toolchain blockers. Play mode, packaging, graphics correctness, and network gameplay still require validation.
