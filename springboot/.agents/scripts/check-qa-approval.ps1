# PreToolUse hook (Antigravity IDE — Windows PowerShell).
# Blocks PR creation unless QA approval is bound to the current commit and branch.
# Output contract: {"decision":"allow|deny|ask","reason":"..."}

try {
    $inputRaw = [Console]::In.ReadToEnd()
    if ([string]::IsNullOrWhiteSpace($inputRaw)) {
        '{"decision":"deny","reason":"Unable to inspect command; QA approval gate failed closed."}'
        exit 0
    }

    $json = $inputRaw | ConvertFrom-Json

    # Extract tool name and command line from Antigravity payload
    $toolName = ""
    $cmd = ""
    if ($json.toolCall) {
        $toolName = [string]$json.toolCall.name
        if ($json.toolCall.args -and $json.toolCall.args.CommandLine) {
            $cmd = [string]$json.toolCall.args.CommandLine
        }
        if ($json.toolCall.args -and $json.toolCall.args.ToolName) {
            $toolName = $toolName + "|" + [string]$json.toolCall.args.ToolName
        }
    }

    $isPrCreation = $cmd -match "(?i)(gh\s+pr\s+create|glab\s+mr\s+create)" -or
        $toolName -match "(?i)create_pull_request"

    # Only gate PR creation commands/tools — allow everything else
    if (-not $isPrCreation) {
        '{"decision":"allow"}'
        exit 0
    }

    # Locate qa-approval.json relative to this script
    $agentsDir = Split-Path $PSScriptRoot -Parent
    $approvalFile = Join-Path $agentsDir "qa-approval.json"
    if (-not (Test-Path $approvalFile)) {
        $approvalFile = Join-Path (Get-Location) ".agents\qa-approval.json"
    }

    if (-not (Test-Path $approvalFile)) {
        '{"decision":"deny","reason":"No QA approval file found. QA must create .agents/qa-approval.json with status APPROVED before a PR can be opened."}'
        exit 0
    }

    $approval = Get-Content $approvalFile -Raw | ConvertFrom-Json

    if ($approval.status -ne "APPROVED") {
        '{"decision":"deny","reason":"QA approval status is not APPROVED (current: ' + $approval.status + ')."}'
        exit 0
    }

    # Validate all required binding fields
    foreach ($field in @("ticket", "branch", "commitSha", "timestamp", "expiresAt")) {
        if ([string]::IsNullOrWhiteSpace([string]$approval.$field)) {
            '{"decision":"deny","reason":"QA approval is missing required field: ' + $field + '."}'
            exit 0
        }
    }

    # Verify approval is bound to the current commit and branch
    try {
        $currentSha = (git rev-parse HEAD 2>$null).Trim()
        $currentBranch = (git branch --show-current 2>$null).Trim()

        if ($approval.commitSha -ne $currentSha) {
            '{"decision":"deny","reason":"QA approval commitSha does not match current HEAD (' + $currentSha.Substring(0, 8) + ')."}'
            exit 0
        }
        if ($approval.branch -ne $currentBranch) {
            '{"decision":"deny","reason":"QA approval branch (' + $approval.branch + ') does not match current branch (' + $currentBranch + ')."}'
            exit 0
        }

        # Verify timestamps
        $now = [DateTimeOffset]::UtcNow
        $approvalDate = [DateTimeOffset]::Parse($approval.timestamp).ToUniversalTime()
        $expiresDate = [DateTimeOffset]::Parse($approval.expiresAt).ToUniversalTime()

        if ($expiresDate -le $now) {
            '{"decision":"deny","reason":"QA approval has expired. QA must re-approve the current commit."}'
            exit 0
        }
        if ($approvalDate -gt $now.AddMinutes(5)) {
            '{"decision":"deny","reason":"QA approval timestamp is in the future — clock skew detected."}'
            exit 0
        }
        if ($approvalDate -gt $expiresDate) {
            '{"decision":"deny","reason":"QA approval timestamps are invalid (timestamp > expiresAt)."}'
            exit 0
        }
    } catch {
        '{"decision":"deny","reason":"QA approval metadata could not be validated against git state."}'
        exit 0
    }

    '{"decision":"allow"}'
    exit 0
} catch {
    # Fail closed — if anything goes wrong, block PR creation
    '{"decision":"deny","reason":"Unable to validate QA approval; PR creation blocked until the QA gate can be evaluated."}'
    exit 0
}
