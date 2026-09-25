# PreToolUse hook (Antigravity IDE — Windows PowerShell).
# Blocks or asks confirmation for "git push --force" targeting main/develop.
# Output contract: {"decision":"allow|deny|ask","reason":"..."}

try {
    $inputRaw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($inputRaw)) {
        '{"decision":"deny","reason":"Unable to inspect command; force-push guard failed closed."}'
        exit 0
    }

    $json = $inputRaw | ConvertFrom-Json

    # Extract command line from Antigravity payload
    $cmd = ""
    if ($json.toolCall -and $json.toolCall.args -and $json.toolCall.args.CommandLine) {
        $cmd = [string]$json.toolCall.args.CommandLine
    }

    # If no command line found, this is not a run_command call — allow
    if ([string]::IsNullOrWhiteSpace($cmd)) {
        '{"decision":"allow"}'
        exit 0
    }

    $isForcePush = $cmd -match "(?i)(^|[;&|\s])git(?:\.exe)?\s+(?:-[^\s]+\s+)*push\s+.*(--force(?:-with-lease|-if-includes)?(?:=|\s|$)|-f(?:\s|$))"
    $isProtectedBranch = $cmd -match "(?i)(^|[/:\s])(main|develop)(?:$|[/:\s])"

    if ($isForcePush -and $isProtectedBranch) {
        '{"decision":"ask","reason":"Force-push to a protected branch (main/develop) requires explicit human confirmation."}'
        exit 0
    }

    '{"decision":"allow"}'
    exit 0
} catch {
    # Fail closed on unexpected errors so the force-push guard is not bypassed
    '{"decision":"deny","reason":"Unable to inspect command; force-push guard failed closed."}'
    exit 0
}
