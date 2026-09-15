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
    if ((Get-Content (Join-Path $Repo 'AGENTS.md') -TotalCount 1) -ne '# Project guide') {
        throw 'Windows hook did not seed the English project guide'
    }
    if ((Get-Content -Raw $env:CD_USAGE_LOG) -notmatch '"platform":"codex"') {
        throw 'Windows hook logged the wrong platform'
    }

    # One directory must reach the log under one spelling whichever writer
    # recorded it: the session record above came from Git Bash's $PWD, while a
    # skill record carries the native path the host sends.
    $SkillPayload = @{
        session_id = 'windows-session'
        cwd        = $Repo
        tool_name  = 'Skill'
        tool_input = @{ skill = 'coding-discipline:tdd' }
    } | ConvertTo-Json -Compress
    Push-Location $Repo
    try {
        $SkillPayload | & (Join-Path $PluginRoot 'hooks\run-hook.cmd') log-usage
        if ($LASTEXITCODE -ne 0) { throw "log-usage exited with $LASTEXITCODE" }
    }
    finally {
        Pop-Location
    }
    # Select-Object -Unique compares case-sensitively; Sort-Object -Unique would
    # hide a drive-letter case split.
    $Spellings = @(Get-Content $env:CD_USAGE_LOG | ForEach-Object { ($_ | ConvertFrom-Json).cwd } | Select-Object -Unique)
    $ExpectedDir = $Repo.Replace('\', '/')
    if ($Spellings.Count -ne 1 -or $Spellings[0] -cne $ExpectedDir) {
        throw "expected every record to read $ExpectedDir, got: $($Spellings -join ' | ')"
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

# Do not let the final native command's $LASTEXITCODE (2 from the
# invalid-platform case) leak into the script exit code.
exit 0
