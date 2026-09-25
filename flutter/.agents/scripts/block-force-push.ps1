# PreToolUse hook for "run_command" (Windows PowerShell)
# Blocks or asks confirmation for "git push --force" targeting main/develop

try {
    $inputRaw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($inputRaw)) {
        '{"decision":"deny","reason":"Unable to inspect command; force-push guard failed closed."}'
        exit 0
    }

    $json = $inputRaw | ConvertFrom-Json
    $cmd = ""
    if ($json.toolCall -and $json.toolCall.args -and $json.toolCall.args.CommandLine) {
        $cmd = $json.toolCall.args.CommandLine
    }

    $isForcePush = $cmd -match "(^|\s)git\s+push\s+.*(--force(?:-with-lease|-if-includes)?(?:=|\s|$)|-f(?:\s|$))"
    $isProtectedBranch = $cmd -match "(main|develop)"

    if ($isForcePush -and $isProtectedBranch) {
        '{"decision":"force_ask","reason":"Force-push to a protected branch (main/develop) requires explicit human confirmation."}'
        exit 0
    }

    '{"decision":"allow"}'
    exit 0
} catch {
    # Fail closed on unexpected errors so the force-push guard is not bypassed
    '{"decision":"deny","reason":"Unable to inspect command; force-push guard failed closed."}'
    exit 0
}
