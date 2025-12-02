#!/bin/bash
# Post initial categorization comment for external PRs
# Usage: post-pr-comment.sh <pr-number> <size> <type> <repository> [summary]

set -e

PR_NUMBER="$1"
SIZE="$2"
TYPE="$3"
REPO="$4"
SUMMARY="$5"

if [ -z "$PR_NUMBER" ] || [ -z "$SIZE" ] || [ -z "$TYPE" ] || [ -z "$REPO" ]; then
  echo "Usage: $0 <pr-number> <size> <type> <repository> [summary]"
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

# Build summary section if available
if [ -n "$SUMMARY" ]; then
  SUMMARY_SECTION="### Summary

$SUMMARY

"
else
  SUMMARY_SECTION=""
fi

# Generate comment based on size
if [ "$SIZE" = "large" ]; then
  # Large PR - different flow (alignment first)
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution!

${SUMMARY_SECTION}### What happens next

We've categorized your PR to provide the right level of validation.

1. **Early alignment** - A squad member will review your approach first
2. **Once aligned** - We'll add the \`alignment-approved\` label
3. **Automated checks** will run (we monitor existing CI/CD)
4. **Code review** - An automation leaves inline comments; fix directly in GitHub and mark resolved when done
5. **Final approval** by a squad member

### What you can do now

- **Add context** about your implementation approach
- **Be ready to discuss** the design with a squad member
- Wait for alignment before addressing detailed feedback

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

Issues with the automated review? Comment \`skip-automated-review\` and let us know.

<!-- external-pr-categorization-comment -->
EOF
else
  # Small/Medium PR - standard flow
  cat > /tmp/categorization-comment.md <<EOF
## ${TYPE_EMOJI} PR Categorized: ${TYPE_NAME} ${SIZE_EMOJI} (Size: ${SIZE})

Thanks for your contribution!

${SUMMARY_SECTION}### What happens next

We've categorized your PR to provide the right level of validation.

1. **Automated checks** will run (we monitor existing CI/CD)
2. **You'll get a checklist** showing what's being validated
3. **Code review** - An automation leaves inline comments; fix directly in GitHub and mark resolved when done
4. **Final approval** by a squad member

### What you can do

- **Push updates anytime** - validation updates automatically!
- Check your validation comment for specific todos
- Address feedback directly in the PR

---

💡 See our [External PR Workflow Guide](../contribute/external-pr-workflow.md) for more details.

Issues with the automated review? Comment \`skip-automated-review\` and let us know.

<!-- external-pr-categorization-comment -->
EOF
fi

# Post comment using gh CLI
gh pr comment "$PR_NUMBER" --repo "$REPO" --body-file /tmp/categorization-comment.md

echo "Posted categorization comment to PR #$PR_NUMBER"
