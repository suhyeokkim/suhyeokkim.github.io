set -e

echo "setting_me.sh"

git config --global user.name "$(git --no-pager show --no-patch --format='%an')"
git config --global user.email "$(git --no-pager show --no-patch --format='%ae')"

echo SSH_REPO
