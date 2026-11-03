param([string]$ClaudeRoot = (Join-Path $env:USERPROFILE '.claude'))
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'skills-lock.json') -Raw | ConvertFrom-Json
$skillRoot = [IO.Path]::GetFullPath((Join-Path $ClaudeRoot 'skills'))
foreach ($repo in $manifest.repositories) {
    $checkout = Join-Path (Join-Path $ClaudeRoot 'skill-repos') (($repo.repo -split '/')[1])
    foreach ($skill in $repo.skills) {
        if ($skill.name -notmatch '^[a-z0-9-]+$') { throw 'Invalid name' }
        $link = [IO.Path]::GetFullPath((Join-Path $skillRoot $skill.name))
        if (-not $link.StartsWith($skillRoot + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Invalid link path' }
        $expected = [IO.Path]::GetFullPath((Join-Path $checkout $skill.path))
        $item = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
        if ($item -and $item.LinkType -eq 'Junction' -and [IO.Path]::GetFullPath($item.Target) -eq $expected) {
            # Delete only the junction itself, never recurse into the repository.
            [IO.Directory]::Delete($link)
            Write-Output "Unlinked $($skill.name)"
        }
    }
}
