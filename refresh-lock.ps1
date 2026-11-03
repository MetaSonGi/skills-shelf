$ErrorActionPreference = 'Stop'
$file = Join-Path $PSScriptRoot 'skills-lock.json'
$manifest = Get-Content -LiteralPath $file -Raw | ConvertFrom-Json
foreach ($repo in $manifest.repositories) {
    $head = & git ls-remote "https://github.com/$($repo.repo).git" HEAD
    if ($LASTEXITCODE -ne 0 -or -not $head) { throw "Cannot read HEAD: $($repo.repo)" }
    $repo.commit = ($head -split '\s+')[0]
}
$manifest.verifiedAt = (Get-Date).ToString('yyyy-MM-dd')
$manifest | ConvertTo-Json -Depth 8 | Set-Content -LiteralPath $file -Encoding utf8
Write-Output 'Lock file refreshed. Review upstream changes, then run install-skills.ps1 to apply.'
