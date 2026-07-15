: << 'CMDBLOCK'
@echo off
setlocal EnableExtensions
REM Cross-platform polyglot wrapper: hand the hook script to the right bash.
REM   Windows: cmd.exe runs this batch block, finds Git-for-Windows bash in
REM            standard locations and calls it (deliberately AVOIDING the WSL
REM            launcher at C:\Windows\System32\bash.exe).
REM   Unix:    the shell reads the whole file as a script -- ":" is a no-op and
REM            the heredoc swallows this batch block, then the Unix tail runs.
REM
REM NOTE: keep this file ASCII-only. cmd.exe parses .cmd under the OEM code page
REM and chokes on UTF-8 multibyte bytes even inside REM comments.
REM
REM Hook scripts use extensionless names (e.g. "session-start-skills") so Claude
REM Code's Windows auto-detection -- which prepends "bash" to any command
REM containing ".sh" -- does not interfere.
REM
REM Usage: run-hook.cmd <script-name> [args...]

if "%~1"=="" (
    echo run-hook.cmd: missing script name >&2
    exit /b 1
)

set "HOOK_DIR=%~dp0"

if exist "C:\Program Files\Git\bin\bash.exe" goto git64
if exist "C:\Program Files (x86)\Git\bin\bash.exe" goto git32
if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" goto gitlocal

REM Fallback: bash on PATH (user-installed Git Bash / MSYS2 / Cygwin).
where bash >nul 2>nul
if errorlevel 1 goto nobash
goto bashpath

REM No bash found: fail clearly so the host can surface the missing dependency.
:nobash
echo run-hook.cmd: Git Bash was not found. Install Git for Windows or put bash on PATH. >&2
exit /b 127

:bashpath
bash --login "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%

:git64
set "PATH=C:\Program Files\Git\usr\bin;C:\Program Files\Git\mingw64\bin;%PATH%"
"C:\Program Files\Git\bin\bash.exe" --noprofile --norc "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%

:git32
set "PATH=C:\Program Files (x86)\Git\usr\bin;C:\Program Files (x86)\Git\mingw32\bin;%PATH%"
"C:\Program Files (x86)\Git\bin\bash.exe" --noprofile --norc "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%

:gitlocal
set "PATH=%LOCALAPPDATA%\Programs\Git\usr\bin;%LOCALAPPDATA%\Programs\Git\mingw64\bin;%PATH%"
"%LOCALAPPDATA%\Programs\Git\bin\bash.exe" --noprofile --norc "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
exit /b %ERRORLEVEL%
CMDBLOCK

# ---- Unix (bash/zsh): run the named script directly ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
