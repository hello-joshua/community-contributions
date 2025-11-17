#!/bin/bash
# Script to post automated PR categorization comment
# Usage: post-pr-comment.sh <pr_number> <size> <type> <repo>

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"

# Start building the comment
cat > /tmp/pr-analysis-comment.md << 'EOF'
## 🤖 Automated PR Analysis

Thank you for your contribution to Grafana! Your PR has been automatically analyzed and categorized.

---

### 📊 PR Categorization

| Category | Value |
|----------|-------|
| **Size** | __SIZE__ |
| **Type** | __TYPE__ |

---

### ⚡ What happens next for __SIZE__ PRs:

**Automated Validation**
- Linting and code formatting checks
- Test verification
- PR requirements validation

EOF

# Add size-specific Review Process section
if [ "$SIZE" = "small" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review Process**
- Lightweight AI review (critical issues only)
- Human review for final approval
- Fast-track validation for simple changes

Your small PR will go through streamlined validation to get you feedback quickly!

EOF
elif [ "$SIZE" = "medium" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review Process**
- Comprehensive AI review (code quality, security, best practices)
- Automatically routed to the relevant squad based on affected areas
- Human review required before merge
- Detailed feedback on implementation

Your medium PR will receive thorough validation and will be assigned to the appropriate team for review.

EOF
elif [ "$SIZE" = "large" ]; then
  cat >> /tmp/pr-analysis-comment.md << 'EOF'
**Review Process**
- **Early alignment checkpoint**: A squad member will review your approach first
- Please be ready to discuss the implementation strategy
- Once aligned, comprehensive validation will run
- Detailed human code review after alignment

⚠️ **Important for Large PRs**: We want to ensure your effort is well-directed before you invest significant time. A maintainer will review the architectural approach and provide feedback. Once we add the `alignment-approved` label, automated validation will proceed.

EOF
fi

# Add common footer sections
cat >> /tmp/pr-analysis-comment.md << 'EOF'
---

### 💡 Tips for Contributors

- Run tests locally before pushing
- Ensure code follows style guidelines  
- Keep descriptions clear and concise
- Respond promptly to feedback

---

### 📚 Resources

- [Contributing Guidelines](https://github.com/grafana/grafana/blob/main/contribute/create-pull-request.md)
- [Community Slack](https://grafana.com/slack)

---

*This analysis was generated automatically. Validation workflows will begin shortly.*
EOF

# Replace placeholders
sed -i "s/__SIZE__/$SIZE/g" /tmp/pr-analysis-comment.md
sed -i "s/__TYPE__/$TYPE/g" /tmp/pr-analysis-comment.md

# Post comment
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/pr-analysis-comment.md

echo "✅ Posted automated comment to PR #$PR_NUMBER (size: $SIZE, type: $TYPE)"

