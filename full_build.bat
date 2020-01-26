@rd /s /q "src\src"
@rd /s /q "src\.nimcache"
@rd /s /q "src\_dlls"
@rd /s /q "src\godotapi"
@rd /s /q ".nimcache"
@del /q nakefile.exe
nake build

@rd /s /q "src\src"
@rd /s /q "src\_dlls"
@rd /s /q ".nimcache"