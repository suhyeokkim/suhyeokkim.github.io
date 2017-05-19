# setting site info for git setting
git clone -b master --depth 1 --quiet "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" _site

# clean up data
rm -r _site/*

# build in "_site" directory
bundle exec jekyll build

# for coveralls
# bundle exec rake
