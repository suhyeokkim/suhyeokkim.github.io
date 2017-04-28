# Travis-ci support may environment variable
# see this for explaination(https://docs.travis-ci.com/user/environment-variables/)
# I use token for github authorize
# you can use password or api token
# see this for explaination(https://docs.travis-ci.com/user/private-dependencies/)

# deployment execute when branch is "source"
if [ "$TRAVIS_BRANCH" == "source" ]
then
  cd _site
  git add -A
  git commit -m "Updated to $(git rev-parse --short $TRAVIS_COMMIT) at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
  git push -f "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" master --quiet
fi
