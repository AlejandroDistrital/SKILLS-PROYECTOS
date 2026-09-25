# PreToolUse hook for "run_command" (Windows PowerShell)
# Blocks PR-creation commands unless .agents/qa-approval.json exists and is APPROVED

try {
    $inputRaw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($inputRaw)) {
        '{"decision":"deny","reason":"Unable to inspect command; QA approval gate failed closed."}'
        exit 0
    }

    $json = $inputRaw | ConvertFrom-Json
    $cmd = ""
    if ($json.toolCall -and $json.toolCall.args -and $json.toolCall.args.CommandLine) {
        $cmd = $json.toolCall.args.CommandLine
    }

    # Only gate PR creation commands (e.g. gh pr create or glab mr create)
    if ($cmd -notmatch "(gh\s+pr\s+create|glab\s+mr\s+create)") {
        '{"decision":"allow"}'
        exit 0
    }

    $approvalFile = Join-Path (Get-Location) ".agents\qa-approval.json"

    if (-not (Test-Path $approvalFile)) {
        '{"decision":"deny","reason":"No QA approval file found. The QA agent must create .agents/qa-approval.json with status APPROVED before a PR can be opened."}'
        exit 0
    }

    $approvalContent = Get-Content $approvalFile -Raw | ConvertFrom-Json

    if ($approvalContent.status -ne "APPROVED") {
        '{"decision":"deny","reason":"Latest QA report status in .agents/qa-approval.json is not APPROVED."}'
        exit 0
    }

    # Check timestamps against git commit if git is available
    if (-not $approvalContent.timestamp) {
        '{"decision":"deny","reason":"QA approval is missing required timestamp metadata."}'
        exit 0
    }

    try {
        $lastCommitTs = [int64](git log -1 --format=%ct 2>$null)
        if ($lastCommitTs -gt 0) {
            $approvalDate = [DateTime]::Parse($approvalContent.timestamp)
            $approvalEpoch = [int64]([DateTimeOffset]$approvalDate).ToUnixTimeSeconds()
            
            if ($approvalEpoch -lt $lastCommitTs) {
                '{"decision":"deny","reason":"QA approval predates the latest commit. Re-run QA tests before opening the PR."}'
                exit 0
            }
        }
    } catch {
        '{"decision":"deny","reason":"QA approval timestamp could not be validated."}'
        exit 0
    }

    '{"decision":"allow"}'
    exit 0
} catch {
    '{"decision":"deny","reason":"Unable to validate QA approval; PR creation is blocked until the QA gate can be evaluated."}'
    exit 0
}
