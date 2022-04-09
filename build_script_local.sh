# clean up prev local data
rm -r -f _site

# setting site info for git setting
git clone -b master --depth 1 "$(git remote get-url origin)" _site

# clean up prev repo data
rm -r _site/*

# build in "_site" directory
bundle exec jekyll build

# move to _site & commit/push
cd _site
git add -A
git commit -m "local update at $(date -u +'%Y-%m-%d %H:%M:%S %Z')"
git push origin master

# remove git
rm -r -f ./.git

# recover origin path
cd ../