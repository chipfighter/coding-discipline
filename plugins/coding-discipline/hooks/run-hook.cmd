: << 'CMDBLOCK'
@echo off
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

if exist "C:\Program Files\Git\bin\bash.exe" (
    "C:\Program Files\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "C:\Program Files (x86)\Git\bin\bash.exe" (
    "C:\Program Files (x86)\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)
if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM Fallback: bash on PATH (user-installed Git Bash / MSYS2 / Cygwin).
where bash >nul 2>nul
if %ERRORLEVEL% equ 0 (
    bash "%HOOK_DIR%%~1" %2 %3 %4 %5 %6 %7 %8 %9
    exit /b %ERRORLEVEL%
)

REM No bash found: exit silently (rest of the plugin still works, just no
REM SessionStart context injection).
exit /b 0
CMDBLOCK

# ---- Unix (bash/zsh): run the named script directly ----
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SCRIPT_NAME="$1"
shift
exec bash "${SCRIPT_DIR}/${SCRIPT_NAME}" "$@"
