@echo off
setlocal enabledelayedexpansion

set "codeCount=0"

for /r %%i in (*.lua) do (
    set /a codeCount+=1
)

echo Total lines of Lua code: %codeCount%
pause >nul
endlocal
