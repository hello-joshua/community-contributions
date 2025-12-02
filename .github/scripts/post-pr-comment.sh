#!/bin/bash
# Post initial categorization comment for external PRs
# Usage: post-pr-comment.sh <pr-number> <size> <type> <repository>

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"

if [ -z "$PR_NUMBER" ] || [ -z "$SIZE" ] || [ -z "$TYPE" ] || [ -z "$REPO" ]; then
  echo "Usage: $0 <pr-number> <size> <type> <repository>"
  exit 1
fi

# Map type for display
case "$TYPE" in
  docs)
    TYPE_EMOJI="📝"
    TYPE_NAME="Documentation"
    ;;
  bugfix)
    TYPE_EMOJI="🐛"
    TYPE_NAME="Bugfix"
    ;;
  feature)
    TYPE_EMOJI="✨"
    TYPE_NAME="Feature"
    ;;
  *)
    TYPE_EMOJI="📦"
    TYPE_NAME="$TYPE"
    ;;
esac

# Map size for display
case "$SIZE" in
  small)
    SIZE_EMOJI="🟢"
    ;;
  medium)
    SIZE_EMOJI="🟡"
    ;;
  large)
    SIZE_EMOJI="🔴"
    ;;
  *)
    SIZE_EMOJI="⚪"
    ;;
esac

# Generate comment based on size
if [ "$SIZE" = "large" ]; then
  # Large PR - different flow (alignment first)
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution! This is a substantial PR, so we'll start with early alignment.

### What happens next

1. **Early alignment** - A squad member will review your approach first
2. **Once aligned** - We'll add the \`alignment-approved\` label
3. **Then automated checks** run and you'll get a validation checklist
4. **Final review** by a squad member

### Why early alignment?

For large PRs, we want to ensure your approach fits with project goals before diving into detailed validation. This saves everyone time!

### What you can do

- **Add context** about your implementation approach
- **Be ready to discuss** the design with a squad member
- Wait for alignment before addressing detailed feedback

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

<!-- external-pr-categorization-comment -->
EOF
else
  # Small/Medium PR - standard flow
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution! We've categorized your PR to provide the right level of validation.

### What happens next

1. **Automated checks** will run (we monitor existing CI/CD)
2. **You'll get a checklist** showing what's being validated
3. **A member of the relevant squad** will provide final approval

### What you can do

- **Push updates anytime** - validation updates automatically!
- Check your validation comment for specific todos
- Address any feedback from automated checks

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

<!-- external-pr-categorization-comment -->
EOF
fi

# Post comment using gh CLI
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/categorization-comment.md

echo "✅ Posted categorization comment to PR #$PR_NUMBER"
