git clone -b master --depth 1 --quiet "https://${TOKEN}@github.com/${TRAVIS_REPO_SLUG}.git" _site
rm -r _site/*
bundle exec jekyll build
bundle exec rake
