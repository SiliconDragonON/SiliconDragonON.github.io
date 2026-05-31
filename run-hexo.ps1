param(
  [Parameter(ValueFromRemainingArguments = $true)]
  [string[]] $HexoArgs
)

$Root = Split-Path -Parent $MyInvocation.MyCommand.Path
$NodeRoot = Join-Path $Root ".tools\node-v24.16.0-win-x64"
$NpmPrefix = Join-Path $Root ".tools\npm-global"
$Hexo = Join-Path $NpmPrefix "hexo.cmd"

if (Test-Path $Hexo) {
  $env:PATH = "$NodeRoot;$NpmPrefix;$Root\node_modules\.bin;$env:PATH"
  & $Hexo @HexoArgs
  exit $LASTEXITCODE
}

$SystemHexo = Get-Command hexo -ErrorAction SilentlyContinue
if ($SystemHexo) {
  & $SystemHexo.Source @HexoArgs
  exit $LASTEXITCODE
}

throw "Hexo CLI was not found. Install Node.js LTS, then run: npm install -g hexo-cli"
