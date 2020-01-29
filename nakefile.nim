# Copyright 2017 Xored Software, Inc.

import nake
import os, ospaths, times
import godotapigen

proc genGodotApi() =
    let godotBin = getEnv("GODOT_BIN")

    if godotBin.len == 0:
        echo "GODOT_BIN environment variable is not set"
        quit(-1)

    if not fileExists(godotBin):
        echo "Invalid GODOT_BIN path: " & godotBin
        quit(-1)

    const targetDir = "src"/"godotapi"
    createDir(targetDir)

    const jsonFile = targetDir/"api.json"
    if not fileExists(jsonFile) or godotBin.getLastModificationTime() > jsonFile.getLastModificationTime():
        direShell(godotBin, "--gdnative-generate-json-api", getCurrentDir()/jsonFile)
        if not fileExists(jsonFile):
            echo "Failed to generate api.json"
            quit(-1)
        genApi(targetDir, jsonFile)

task "build", "Builds the client for the current platform":
    genGodotApi()

    let bitsPostfix = when sizeof(int) == 8: "_64" else: "_32"
    let libFile =
        when defined(windows):   "nim" & bitsPostfix & ".dll"
        elif defined(ios):       "nim_ios" & bitsPostfix & ".dylib"
        elif defined(macosx):    "nim_mac.dylib"
        elif defined(android):   "libnim_android.so"
        elif defined(linux):     "nim_linux" & bitsPostfix & ".so"
        else:                    nil

    createDir("_dlls")

    withDir "src":    # direShell loops forever when errors occur
        # direShell(["nimble", "c", ".."/"src"/"stub.nim", "-o:.."/"_dlls"/libFile])
        shell(["nimble", "c", "--oldgensym:on", ".."/"src"/"stub.nim", "-o:.."/"_dlls"/libFile])


task "release", "Builds the client for the current platform":
    genGodotApi()

    let bitsPostfix = when sizeof(int) == 8: "_64" else: "_32"
    let libFile =
        when defined(windows):   "nim" & bitsPostfix & ".dll"
        elif defined(ios):       "nim_ios" & bitsPostfix & ".dylib"
        elif defined(macosx):    "nim_mac.dylib"
        elif defined(android):   "libnim_android.so"
        elif defined(linux):     "nim_linux" & bitsPostfix & ".so"
        else:                    nil

    createDir("_dlls")

    withDir "src":    # direShell loops forever when errors occur
        # direShell(["nimble", "c", ".."/"src"/"stub.nim", "-o:.."/"_dlls"/libFile])
        shell(["nimble", "c", "-d:release", "--oldgensym:on", ".."/"src"/"stub.nim", "-o:.."/"_dlls"/libFile])


task "clean", "Remove files produced by build":
    removeDir(".nimcache")
    removeDir("src"/".nimcache")
    removeDir("src"/"godotapi")
    removeDir("_dlls")
    removeFile("nakefile.exe")
