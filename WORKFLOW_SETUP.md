# GitHub Actions Workflow Setup

This repository includes an automated workflow that commits meaningful thoughts twice daily.

## Features

- **Runs twice daily** at 8 AM and 8 PM UTC
- **AI-powered thoughts** using OpenRouter API (with fallback)
- **Random commits per run**: 1-5 commits, ensuring max 8 commits/day
- **Smart limiting**: Tracks daily commit count and stops at 8
- **Manual trigger**: Can be triggered manually via GitHub Actions UI

## Setup Instructions

### 1. Add OpenRouter API Key (Optional)

If you want AI-generated thoughts, add your OpenRouter API key as a repository secret:

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Secrets and variables** → **Actions**
3. Click **New repository secret**
4. Name: `OPENROUTER_API_KEY`
5. Value: Your OpenRouter API key (get it from https://openrouter.ai/)
6. Click **Add secret**

> **Note**: If no API key is provided, the workflow will use pre-defined fallback thoughts.

### 2. Enable GitHub Actions

1. Go to your repository on GitHub
2. Navigate to **Settings** → **Actions** → **General**
3. Under "Workflow permissions", ensure:
   - ✅ **Read and write permissions** is selected
   - ✅ **Allow GitHub Actions to create and approve pull requests** (optional)
4. Click **Save**

### 3. Verify Workflow

1. Go to **Actions** tab in your repository
2. You should see "Daily Commits" workflow
3. You can manually trigger it by clicking **Run workflow**

## How It Works

### Daily Commit Logic

- **First run (8 AM UTC)**: Creates 1-5 random commits
- **Second run (8 PM UTC)**: Creates 1-5 random commits
- **Total daily limit**: Maximum 8 commits per day
- If the daily limit is reached, the workflow skips execution

### Commit Content

Each commit adds a meaningful development thought to `README.md` with:
- Timestamp
- Insightful thought about software development
- Topics: clean code, testing, architecture, security, DevOps, etc.

### Example Commits

```
docs: Refactoring improves code maintainability and readability.
docs: Writing tests first helps clarify requirements.
docs: Code reviews catch bugs early and share knowledge.
```

## Manual Trigger

To manually run the workflow:

1. Go to **Actions** tab
2. Select "Daily Commits" workflow
3. Click **Run workflow** → **Run workflow**

## Customization

Edit `.github/workflows/daily-commits.yml` to customize:

- **Schedule**: Modify the `cron` expressions
  ```yaml
  - cron: '0 8 * * *'   # 8 AM UTC
  - cron: '0 20 * * *'  # 8 PM UTC
  ```

- **Daily limit**: Change the max commits per day (line 41)
  ```powershell
  $remaining = 8 - $commitCount  # Change 8 to your desired limit
  ```

- **Commits per run**: Adjust the range (line 60)
  ```powershell
  $numCommits = Get-Random -Minimum 1 -Maximum 6  # Change range
  ```

- **AI Model**: Change the OpenRouter model (line 107)
  ```powershell
  model = "minimax/minimax-m2:free"  # Or another model
  ```

## Troubleshooting

### Workflow not running?

- Check if Actions are enabled in repository settings
- Verify workflow permissions (read/write access)
- Check the Actions tab for error logs

### No AI thoughts generated?

- Verify `OPENROUTER_API_KEY` secret is set correctly
- Check OpenRouter API credits
- Fallback thoughts will be used automatically if AI fails

### Too many/few commits?

- Adjust the random range in the workflow file
- Modify the daily limit value
- Check workflow run history in Actions tab

## Schedule Times

The workflow runs at:
- **8:00 AM UTC** (adjust for your timezone)
- **8:00 PM UTC** (adjust for your timezone)

Convert to your timezone:
- UTC to EST: subtract 5 hours
- UTC to PST: subtract 8 hours
- UTC to IST: add 5.5 hours

## License

This workflow is provided as-is for personal use in maintaining repository activity.
