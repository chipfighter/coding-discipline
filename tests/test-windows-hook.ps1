$ErrorActionPreference = 'Stop'

$Root = (Resolve-Path (Join-Path $PSScriptRoot '..')).Path
$PluginRoot = Join-Path $Root 'plugins\coding-discipline'
$Hooks = Get-Content -Raw (Join-Path $PluginRoot 'hooks\hooks-codex.json') | ConvertFrom-Json
$CommandWindows = $Hooks.hooks.SessionStart[0].hooks[0].commandWindows
$TempBase = [IO.Path]::GetFullPath([IO.Path]::GetTempPath())
$TempRoot = Join-Path $TempBase ('coding-discipline-tests-' + [guid]::NewGuid().ToString('N'))
$Repo = Join-Path $TempRoot 'repo'

try {
    New-Item -ItemType Directory -Path $Repo | Out-Null
    & git -C $Repo init --quiet
    if ($LASTEXITCODE -ne 0) { throw 'git init failed' }
    & git -C $Repo -c user.name=tests -c user.email=tests@example.com commit --allow-empty -m initial --quiet
    if ($LASTEXITCODE -ne 0) { throw 'git commit failed' }

    $env:PLUGIN_ROOT = $PluginRoot
    $env:CLAUDE_PLUGIN_ROOT = $PluginRoot
    $env:PLUGIN_DATA = Join-Path $TempRoot 'plugin-data'
    $env:CD_USAGE_LOG = Join-Path $TempRoot 'usage.jsonl'
    Remove-Item Env:CODEX_HOME -ErrorAction SilentlyContinue

    Push-Location $Repo
    try {
        $Output = Invoke-Expression $CommandWindows 2>&1
        if ($LASTEXITCODE -ne 0) { throw "Windows hook exited with $LASTEXITCODE`: $Output" }
    }
    finally {
        Pop-Location
    }

    $Payload = ($Output -join "`n") | ConvertFrom-Json
    if ($Payload.hookSpecificOutput.hookEventName -ne 'SessionStart') {
        throw 'Windows hook did not emit SessionStart JSON'
    }
    if (-not (Test-Path (Join-Path $Repo 'AGENTS.md'))) { throw 'Windows hook did not create AGENTS.md' }
    if (Test-Path (Join-Path $Repo 'CLAUDE.md')) { throw 'Windows hook created CLAUDE.md' }
    if ((Get-Content -Raw $env:CD_USAGE_LOG) -notmatch '"platform":"codex"') {
        throw 'Windows hook logged the wrong platform'
    }

    Push-Location $Repo
    try {
        $PreviousPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Continue'
        & (Join-Path $PluginRoot 'hooks\run-hook.cmd') session-start-skills invalid-platform 2>$null
        $WrapperExit = $LASTEXITCODE
        $ErrorActionPreference = $PreviousPreference
        if ($WrapperExit -ne 2) { throw "wrapper did not preserve exit code 2 (got $WrapperExit)" }
    }
    finally {
        Pop-Location
    }

    Write-Output 'Windows hook tests passed'
}
finally {
    $ResolvedTemp = [IO.Path]::GetFullPath($TempRoot)
    if ($ResolvedTemp.StartsWith($TempBase, [StringComparison]::OrdinalIgnoreCase) -and
        (Split-Path $ResolvedTemp -Leaf).StartsWith('coding-discipline-tests-')) {
        Remove-Item -LiteralPath $ResolvedTemp -Recurse -Force -ErrorAction SilentlyContinue
    }
    else {
        throw "refusing to remove unexpected test path: $ResolvedTemp"
    }
}
