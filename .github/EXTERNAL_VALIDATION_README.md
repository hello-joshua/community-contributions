# External PR Validation System

This document explains how the type-specific PR validation system works for external contributors.

## Overview

The external PR validation system provides a friendly, automated workflow that:
- Monitors existing Grafana CI/CD workflows (no duplicate runs)
- Presents clear, actionable todo lists based on PR type and size
- Uses AI to provide positive, focused feedback on code quality and tests
- Consolidates all feedback into a single, helpful comment

## Architecture

### Components

```
.github/
├── templates/                         # Todo list templates
│   ├── todos-small.md                # Small PR checklist (3 type sections)
│   ├── todos-medium.md               # Medium PR checklist
│   └── todos-large.md                # Large PR checklist (with alignment phase)
│
├── actions/external-pr-validation/   # Reusable validation actions
│   ├── monitor-workflows/            # Watches existing CI/CD workflows
│   ├── assess-quality/               # AI quality assessment
│   └── post-validation-comment/      # Consolidated comment generator
│
├── workflows/                         # Validation workflows
│   ├── categorize-external-pr-simple.yml  # Categorizes PRs by size/type
│   ├── validate-small-pr.yml         # Small PR validation
│   ├── validate-medium-pr.yml        # Medium PR validation
│   └── validate-large-pr.yml         # Large PR validation (2-phase)
│
└── scripts/
    └── post-pr-comment.sh             # Initial categorization comment
```

### Workflow Flow

1. **External PR submitted** → `categorize-external-pr-simple.yml` runs
2. **PR categorized** by size (small/medium/large) and type (docs/bugfix/feature)
3. **Appropriate validation workflow** triggers based on labels
4. **Validation workflow**:
   - Monitors existing CI/CD workflows (no duplicate runs)
   - Runs AI quality assessment
   - Posts consolidated comment with todo list and feedback
   - Notifies squad if validation passes
5. **Contributor** sees single comment with clear next steps

## Type-Specific Validation

### Docs PRs (type/docs)

**Monitored workflows:**
- `Documentation CI` (Vale prose linting)

**AI assessment focus:**
- Content clarity and helpfulness
- Structure appropriate for size

**What we don't check:**
- Code linting/tests (not applicable)
- Link validation (docs team handles)

### Bugfix PRs (type/bug)

**Monitored workflows:**
- `Lint Frontend`
- `golangci-lint` (backend)
- `Frontend tests`
- `Backend Unit Tests`

**AI assessment focus:**
- Do tests verify the fix?
- Any new bugs introduced?
- Is the fix focused (not scope creep)?

**What we don't check:**
- Issue number requirement (not enforced)
- Design docs (not required)

### Feature PRs (type/feature)

**Monitored workflows:**
- `Lint Frontend`
- `golangci-lint` (backend)
- `Frontend tests`
- `Backend Unit Tests`

**AI assessment focus:**
- Do tests cover new functionality?
- Code quality and maintainability
- Obvious bugs or edge cases missed?

**What we don't check:**
- Design docs, migration guides, API docs (not required)
- Breaking change analysis (handled by Cursor Bugbot separately)

## Size-Specific Behavior

### Small PRs (🟢)

- **Validation**: Lightweight, quick checks
- **AI review**: Brief feedback, 2-3 sentences max
- **Timeline**: 1-2 days

### Medium PRs (🟡)

- **Validation**: Comprehensive checks
- **AI review**: More thorough, still concise
- **Timeline**: 2-5 days

### Large PRs (🔴)

- **Phase 1**: Early alignment (human review before automation)
- **Phase 2**: Focused validation after `alignment-approved` label added
- **AI review**: Critical issues only
- **Timeline**: 1-2 weeks

## AI Quality Assessment

### How It Works

The `assess-quality` action uses OpenAI (gpt-4o-mini) to review PRs with these principles:

**Always:**
- Be encouraging and positive
- Keep feedback to 2-3 sentences max
- Only mention critical issues
- Start with something positive
- Use friendly language, not demands

**Never:**
- Nitpick about cosmetic issues
- Require design docs, migration guides, etc.
- Assess PR descriptions (code speaks for itself)
- Enforce issue number references

### Fallback Behavior

If no OpenAI API key is configured:
- AI assessment is skipped gracefully
- System still works with traditional checks
- Comment notes AI unavailable

## Configuration

### Secrets

- `OPEN_AI_KEY`: Used for AI quality assessment (required for AI features)
- `SLACK_WEBHOOK_*`: Used for squad notifications (existing configuration)

### Customization

#### Modify Todo Templates

Edit files in `.github/templates/`:
- `todos-small.md`
- `todos-medium.md`
- `todos-large.md`

Each template has three sections (docs/bugfix/feature) separated by `<!-- TYPE SECTION -->` comments and `---` dividers.

#### Adjust Monitored Workflows

Edit `.github/actions/external-pr-validation/monitor-workflows/action.yml`:
- Modify the `WORKFLOWS` variable for each type
- Workflow names must match exactly as they appear in GitHub Actions

#### Change AI Behavior

Edit `.github/actions/external-pr-validation/assess-quality/action.yml`:
- Modify the `FOCUS` prompts for each type
- Adjust temperature, max_tokens, or model
- Change how concerns are detected

## Troubleshooting

### Validation Comment Not Appearing

**Check:**
1. Is the PR labeled with `size:*` and `type/*` labels?
2. Did the categorization workflow complete successfully?
3. Check GitHub Actions logs for errors

### Workflows Showing as Pending Forever

**Possible causes:**
1. Workflows haven't run yet (wait a few minutes)
2. PR doesn't touch relevant files (workflows skipped by change detection)
3. Check individual workflow status in GitHub Actions tab

### AI Assessment Skipped

**Reasons:**
1. `OPEN_AI_KEY` secret not configured
2. API quota exceeded
3. API error (check workflow logs)

**Solution:**
- System still works without AI
- Configure API key if desired
- AI provides helpful but not critical feedback

### Comment Updates Not Working

**Check:**
1. Ensure comment has the `<!-- external-pr-validation-comment -->` marker
2. Check for API permissions issues
3. Review workflow logs for errors

## Maintenance

### Regular Tasks

- **Monitor AI feedback quality**: Review comments to ensure helpfulness
- **Update templates**: Adjust based on contributor feedback
- **Review monitored workflows**: Ensure list stays current as CI/CD evolves
- **Check API usage**: Monitor OpenAI API quota and costs

### When CI/CD Changes

If Grafana adds/renames workflows:

1. Update `monitor-workflows/action.yml` with new workflow names
2. Test with a sample PR
3. Update this documentation

## For Contributors

See [external-pr-workflow.md](../contribute/external-pr-workflow.md) for the contributor-facing guide.

## Support

- **Issues**: Create with `workflow-automation` label
- **Questions**: Ask in `#grafana-automation` Slack channel
- **Feedback**: Open discussions in `#external-contributors`

---

**Version:** 1.0  
**Last Updated:** 2025-01-19  
**Maintained By:** Platform Team

