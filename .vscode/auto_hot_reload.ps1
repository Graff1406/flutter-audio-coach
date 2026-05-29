$ErrorActionPreference = 'Stop'

$projectRoot = Resolve-Path (Join-Path $PSScriptRoot '..')
$flutter = 'E:\flutter\bin\flutter.bat'
$port = '5050'
$logPath = Join-Path $projectRoot '.vscode\auto_hot_reload.log'

Start-Transcript -Path $logPath -Force | Out-Null

Set-Location $projectRoot

if (-not (Test-Path -LiteralPath $flutter)) {
  Write-Host "Flutter executable was not found at $flutter" -ForegroundColor Red
  exit 1
}

Write-Host "Starting Flutter dev server on http://localhost:$port"
Write-Host "Hot reload is automatic when files in lib/ or pubspec.* are saved."
Write-Host "Stop this VS Code task to quit."

$psi = [System.Diagnostics.ProcessStartInfo]::new()
$psi.FileName = $flutter
$psi.Arguments = "run -d web-server --web-port $port --web-hostname localhost --no-web-resources-cdn"
$psi.WorkingDirectory = $projectRoot
$psi.UseShellExecute = $false
$psi.RedirectStandardInput = $true
$psi.RedirectStandardOutput = $false
$psi.RedirectStandardError = $false
$psi.CreateNoWindow = $false

$global:flutterHotReloadProcess = [System.Diagnostics.Process]::new()
$global:flutterHotReloadProcess.StartInfo = $psi
$global:flutterHotReloadProcess.EnableRaisingEvents = $true
$global:lastHotReloadAt = [DateTime]::MinValue

try {
  [void]$global:flutterHotReloadProcess.Start()
} catch {
  Write-Host "Could not start Flutter: $_" -ForegroundColor Red
  throw
}

function Invoke-FlutterHotReload {
  $now = Get-Date
  if (($now - $global:lastHotReloadAt).TotalMilliseconds -lt 900) {
    return
  }

  $global:lastHotReloadAt = $now
  if ($global:flutterHotReloadProcess.HasExited) {
    return
  }

  try {
    Write-Host "File saved. Sending hot reload..." -ForegroundColor Cyan
    $global:flutterHotReloadProcess.StandardInput.WriteLine('r')
    $global:flutterHotReloadProcess.StandardInput.Flush()
  } catch {
    Write-Host "Could not send hot reload: $_" -ForegroundColor Yellow
  }
}

$watchers = @()
$registrations = @()

$libPath = Join-Path $projectRoot 'lib'
if (Test-Path $libPath) {
  $watcher = [System.IO.FileSystemWatcher]::new($libPath, '*.dart')
  $watcher.IncludeSubdirectories = $true
  $watcher.EnableRaisingEvents = $true
  $watchers += $watcher
  $registrations += Register-ObjectEvent $watcher Changed -Action { Invoke-FlutterHotReload }
  $registrations += Register-ObjectEvent $watcher Created -Action { Invoke-FlutterHotReload }
  $registrations += Register-ObjectEvent $watcher Renamed -Action { Invoke-FlutterHotReload }
}

$rootWatcher = [System.IO.FileSystemWatcher]::new($projectRoot, 'pubspec.*')
$rootWatcher.IncludeSubdirectories = $false
$rootWatcher.EnableRaisingEvents = $true
$watchers += $rootWatcher
$registrations += Register-ObjectEvent $rootWatcher Changed -Action { Invoke-FlutterHotReload }

try {
  while (-not $global:flutterHotReloadProcess.HasExited) {
    Start-Sleep -Milliseconds 100
  }

  $global:flutterHotReloadProcess.WaitForExit()
  $exitCode = $global:flutterHotReloadProcess.ExitCode
  Write-Host "Flutter process exited with code $exitCode." -ForegroundColor Yellow
  exit $exitCode
} catch {
  Write-Host "Auto hot reload task failed: $_" -ForegroundColor Red
  throw
} finally {
  foreach ($registration in $registrations) {
    Unregister-Event -SubscriptionId $registration.Id -ErrorAction SilentlyContinue
  }
  foreach ($watcher in $watchers) {
    $watcher.Dispose()
  }
  if ($global:flutterHotReloadProcess -and -not $global:flutterHotReloadProcess.HasExited) {
    try {
      $global:flutterHotReloadProcess.StandardInput.WriteLine('q')
    } catch {
      Write-Host "Could not stop Flutter cleanly: $_" -ForegroundColor Yellow
    }
  }
  Stop-Transcript | Out-Null
}
