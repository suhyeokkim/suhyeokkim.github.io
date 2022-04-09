# clean up prev local data
rm -r -f _site

# setting site info for git setting
git clone -b master --depth 1 "https://github.com/suhyeokkim/suhyeokkim.github.io.git" _site

# clean up prev repo data
rm -r _site/*

# build in "_site" directory
bundle exec jekyll build

# move to _site & commit/push
cd _site
git add -A
git commit -m "Updated to $(git rev-parse --short local_update) at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
git push -f "https://github.com/suhyeokkim/suhyeokkim.github.io.git" master

cd ../