echo "$TRAVIS_BRANCH"
if [ "$TRAVIS_BRANCH" == "source" ]
then
  cd _site
  git add -A
  git commit -m "Updated to $(git rev-parse --short $TRAVIS_COMMIT) at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
  git push -f "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" master --quiet
fi
