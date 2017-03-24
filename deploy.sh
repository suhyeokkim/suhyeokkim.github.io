set -e

echo "deploy.sh"

# Save some useful variables
TARGET_BRANCH="master"
OUTPUT_DIR="_site"
SHA=`git rev-parse --verify HEAD`
REPO=`git config remote.origin.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

cd $OUTPUT_DIR
git add -A
git commit -m "Deploy to GitHub Pages: ${SHA} at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"

echo "PUSH -F"

# Push it
git push -f https://github.com/hrmrzizon/hrmrzizon.github.com.git $TARGET_BRANCH
