param([string]$ClaudeRoot = (Join-Path $env:USERPROFILE '.claude'), [string]$SeedRoot)
$ErrorActionPreference = 'Stop'
$manifest = Get-Content -LiteralPath (Join-Path $PSScriptRoot 'skills-lock.json') -Raw | ConvertFrom-Json
$repoRoot = Join-Path $ClaudeRoot 'skill-repos'
$skillRoot = Join-Path $ClaudeRoot 'skills'
New-Item -ItemType Directory -Force -Path $repoRoot,$skillRoot | Out-Null
function GitChecked([string[]]$GitArgs) {
    & git @GitArgs
    if ($LASTEXITCODE -ne 0) { throw "Git failed: $($GitArgs -join ' ')" }
}
$report = @()
foreach ($repo in $manifest.repositories) {
    $shortName = ($repo.repo -split '/')[1]
    $checkout = Join-Path $repoRoot $shortName
    $url = "https://github.com/$($repo.repo).git"
    if (-not (Test-Path -LiteralPath $checkout)) {
        $seed = if ($SeedRoot) { Join-Path $SeedRoot $shortName } else { $null }
        if ($seed -and (Test-Path -LiteralPath $seed)) {
            GitChecked @('clone','--local','--no-hardlinks',$seed,$checkout)
            GitChecked @('-C',$checkout,'remote','set-url','origin',$url)
        } else { GitChecked @('clone',$url,$checkout) }
    }
    $remote = (& git -C $checkout remote get-url origin).Trim()
    if ($LASTEXITCODE -ne 0 -or $remote -ne $url) { throw "Unexpected remote: $checkout" }
    $dirty = & git -C $checkout status --porcelain
    if ($LASTEXITCODE -ne 0 -or $dirty) { throw "Checkout has local edits: $checkout" }
    & git -C $checkout cat-file -e "$($repo.commit)^{commit}" 2>$null
    if ($LASTEXITCODE -ne 0) { GitChecked @('-C',$checkout,'fetch','origin',$repo.commit) }
    GitChecked @('-C',$checkout,'checkout','--detach',$repo.commit)
    foreach ($skill in $repo.skills) {
        if ($skill.name -notmatch '^[a-z0-9-]+$') { throw 'Invalid skill name' }
        $target = [IO.Path]::GetFullPath((Join-Path $checkout $skill.path))
        $checkoutFull = [IO.Path]::GetFullPath($checkout)
        if ($target -ne $checkoutFull -and -not $target.StartsWith($checkoutFull + [IO.Path]::DirectorySeparatorChar,[StringComparison]::OrdinalIgnoreCase)) { throw 'Skill target outside checkout' }
        if (-not (Test-Path -LiteralPath (Join-Path $target 'SKILL.md'))) { throw "Missing SKILL.md: $target" }
        $link = Join-Path $skillRoot $skill.name
        $existing = Get-Item -LiteralPath $link -Force -ErrorAction SilentlyContinue
        if ($existing) {
            if ($existing.LinkType -eq 'Junction' -and [IO.Path]::GetFullPath($existing.Target) -eq $target) { $status = 'linked' }
            else { Write-Warning "Keeping existing skill: $link"; $status = 'skipped-existing' }
        } else {
            New-Item -ItemType Junction -Path $link -Target $target | Out-Null
            $status = 'linked'
        }
        $report += [pscustomobject]@{name=$skill.name;repo=$repo.repo;commit=$repo.commit;status=$status}
    }
}
$report | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $PSScriptRoot 'installed.local.json') -Encoding utf8
$report | Format-Table name,status
Write-Output 'Restart Claude Code, then check /skills. See README.md for invocation examples.'
