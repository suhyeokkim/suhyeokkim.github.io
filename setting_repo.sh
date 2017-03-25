set -e

echo "setting_repo.sh"

OUTPUT_DIR="_site"
REPO=`git config remote.setting.url`
SSH_REPO=${REPO/https:\/\/github.com\//git@github.com:}

git clone -b master https://github.com/hrmrzizon/hrmrzizon.github.com.git $OUTPUT_DIR
