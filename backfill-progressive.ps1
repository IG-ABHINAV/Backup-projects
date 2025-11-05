# Backfill commits with progressive pattern
# July 22 - Aug 22: 1-2 commits/day
# Aug 23 onwards: ramp up from 5-6/day to 10-12/day
# Skip Sundays

param(
    [string]$OpenRouterApiKey = $env:OPENROUTER_API_KEY,
    [string]$Model = $env:OPENROUTER_MODEL,
    [switch]$UseAI,
    [int]$AIThoughtsCount = 500
)

# Default to free minimax model if not specified
if (-not $Model) {
    $Model = "minimax/minimax-m2:free"
}

$startDate = Get-Date "2023-01-01"
$endDate = Get-Date
$firstMonthEnd = $startDate.AddMonths(1)

function Get-AIThoughts {
    param(
        [string]$ApiKey,
        [string]$Model,
        [int]$Count = 500
    )
    
    if (-not $ApiKey) {
        Write-Warning "No OpenRouter API key provided. Using fallback thoughts."
        return $null
    }
    
    Write-Host "Generating $Count fresh thoughts using AI..."
    Write-Host "Model: $Model"
    
    $prompt = @"
Generate exactly $Count unique, insightful thoughts about software development, coding best practices, engineering principles, and developer wisdom.

Requirements:
- Each thought should be 1 concise sentence (10-15 words)
- Focus on: clean code, testing, architecture, collaboration, performance, security, DevOps, debugging, documentation
- Make them practical and actionable
- No numbering or bullet points
- One thought per line
- Vary the topics and depth

Examples:
- "Refactoring improves code maintainability and readability."
- "Writing tests first helps clarify requirements."
- "Code reviews catch bugs early and share knowledge."

Generate $Count similar thoughts now:
"@
    
    $body = @{
        model = $Model
        messages = @(
            @{
                role = "user"
                content = $prompt
            }
        )
        temperature = 0.8
        max_tokens = 8000
    } | ConvertTo-Json -Depth 10
    
    try {
        $headers = @{
            "Authorization" = "Bearer $ApiKey"
            "Content-Type" = "application/json"
            "HTTP-Referer" = "https://github.com/backfill-commits"
        }
        
        $response = Invoke-RestMethod -Uri "https://openrouter.ai/api/v1/chat/completions" `
            -Method Post `
            -Headers $headers `
            -Body $body `
            -TimeoutSec 60
        
        $content = $response.choices[0].message.content
        $generatedThoughts = $content -split "`n" | Where-Object { $_.Trim() -ne "" -and $_.Length -gt 20 }
        
        Write-Host "Successfully generated $($generatedThoughts.Count) thoughts!"
        return $generatedThoughts
    }
    catch {
        Write-Warning "AI generation failed: $($_.Exception.Message). Using fallback thoughts."
        return $null
    }
}

# Extended fallback thoughts
$thoughts = @(
    "Refactoring improves code maintainability and readability.",
    "Writing tests first helps clarify requirements.",
    "Code reviews catch bugs early and share knowledge.",
    "Documentation is essential for team collaboration.",
    "Clean code is easier to understand and modify.",
    "Small, focused commits make debugging easier.",
    "Performance optimization should be based on profiling.",
    "Consistency in coding style reduces cognitive load.",
    "Error handling is as important as the happy path.",
    "Security should be considered from the start.",
    "Automated testing saves time in the long run.",
    "Simple solutions are often the best solutions.",
    "Technical debt should be addressed incrementally.",
    "Good naming makes code self-documenting.",
    "Modular design enables easier testing and reuse.",
    "Version control enables safe experimentation.",
    "Regular refactoring prevents code decay.",
    "Understanding the problem deeply leads to better solutions.",
    "Code should be optimized for readability first.",
    "Incremental changes reduce risk.",
    "Learning from mistakes is part of growth.",
    "Collaboration enhances solution quality.",
    "Design patterns solve common problems elegantly.",
    "DRY principle: Don't Repeat Yourself.",
    "YAGNI: You Aren't Gonna Need It.",
    "KISS: Keep It Simple, Stupid.",
    "Separation of concerns improves maintainability.",
    "Immutability reduces bugs in concurrent code.",
    "Logging helps diagnose production issues.",
    "Configuration should be separate from code.",
    "Backups prevent catastrophic data loss.",
    "Monitoring provides visibility into system health.",
    "Scalability should be planned, not retrofitted.",
    "API design affects long-term maintainability.",
    "Edge cases reveal design weaknesses.",
    "User feedback drives meaningful improvements.",
    "Dependencies should be carefully evaluated.",
    "Build automation ensures consistency.",
    "Code coverage metrics guide testing efforts.",
    "Profiling reveals actual bottlenecks.",
    "Database indexing dramatically improves query performance.",
    "Caching strategically reduces server load significantly.",
    "Input validation prevents security vulnerabilities.",
    "Meaningful error messages improve debugging efficiency.",
    "Code duplication increases maintenance burden unnecessarily.",
    "Feature flags enable safer progressive rollouts.",
    "Load testing reveals system breaking points.",
    "Continuous integration catches integration issues early.",
    "Documentation should evolve with the codebase.",
    "Type safety catches errors at compile time."
)

# Try to get AI-generated thoughts if requested
if ($UseAI) {
    $aiThoughts = Get-AIThoughts -ApiKey $OpenRouterApiKey -Model $Model -Count $AIThoughtsCount
    if ($aiThoughts -and $aiThoughts.Count -gt 0) {
        $thoughts = $aiThoughts
        Write-Host "Using $($thoughts.Count) AI-generated thoughts"
    }
}

# Create initial files
@"
# Backup Projects

A collection of development insights and best practices.

"@ | Out-File -FilePath "README.md" -Encoding UTF8

@"
node_modules/
*.log
.DS_Store
"@ | Out-File -FilePath ".gitignore" -Encoding UTF8

Write-Host "Backfilling commits from $($startDate.ToString('yyyy-MM-dd')) to $($endDate.ToString('yyyy-MM-dd'))"
Write-Host "Random commits: 15-25 commits/day (average ~20)"
Write-Host "Including all days (no skipping Sundays)"
Write-Host "Total thoughts available: $($thoughts.Count)"

$totalDays = 0
$totalCommits = 0
$thoughtIndex = 0

$current = $startDate
while ($current -le $endDate) {
    # Completely random commits per day: 15-25 for average of 20
    $numCommits = Get-Random -Minimum 15 -Maximum 26
    
    for ($i = 1; $i -le $numCommits; $i++) {
        # Random time between 9 AM and 9 PM
        $hour = Get-Random -Minimum 9 -Maximum 22
        $minute = Get-Random -Minimum 0 -Maximum 60
        $commitTime = Get-Date -Year $current.Year -Month $current.Month -Day $current.Day -Hour $hour -Minute $minute -Second 0
        $commitDate = $commitTime.ToString("yyyy-MM-dd HH:mm:ss")
        
        # Add a meaningful thought to README
        $thought = $thoughts[$thoughtIndex % $thoughts.Count]
        $thoughtIndex++
        
        $entry = "`n## $($commitTime.ToString('yyyy-MM-dd HH:mm'))`n- $thought`n"
        $entry | Out-File -FilePath "README.md" -Append -Encoding UTF8 -Force
        
        # Ensure file is released before git operations
        Start-Sleep -Milliseconds 200
        
        # Commit with backdated timestamp
        git add README.md 2>&1 | Out-Null
        $env:GIT_AUTHOR_DATE = $commitDate
        $env:GIT_COMMITTER_DATE = $commitDate
        git commit -m "docs: $($current.ToString('MMM dd')) - $thought" 2>&1 | Out-Null
        
        Write-Host "  [$i/$numCommits] $($commitTime.ToString('HH:mm')): $thought" -ForegroundColor Gray
        
        $totalCommits++
    }
    
    $totalDays++
    
    # Show progress periodically
    if ($current.Day -eq 1 -or $totalCommits % 200 -eq 0) {
        Write-Host "$($current.ToString('yyyy-MM-dd')): $numCommits commits (Total: $totalCommits)"
    }
    
    $current = $current.AddDays(1)
}

# Reset env vars
$env:GIT_AUTHOR_DATE = $null
$env:GIT_COMMITTER_DATE = $null

Write-Host "`n===== Summary ====="
Write-Host "Days with commits: $totalDays"
Write-Host "Total commits: $totalCommits"
Write-Host "`nReview: git log --oneline"
Write-Host "Push when ready: git push"
