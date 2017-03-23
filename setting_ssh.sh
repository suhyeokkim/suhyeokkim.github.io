set -e

echo "setting_ssh.sh"

git config --global user.name "$(git --no-pager show --no-patch --format='%an')"
git config --global user.email "$(git --no-pager show --no-patch --format='%ae')"

# setting environment parameter

ENCRYPTED_KEY_VAR="encrypted_${ENCRYPTION_LABEL}_key"
ENCRYPTED_IV_VAR="encrypted_${ENCRYPTION_LABEL}_iv"
ENCRYPTED_KEY=${!ENCRYPTED_KEY_VAR}
ENCRYPTED_IV=${!ENCRYPTED_IV_VAR}

# start key setting

mkdir -p .ssh
openssl aes-256-cbc -K $ENCRYPTED_KEY -iv $ENCRYPTED_IV -in deploy_key.enc -out deploy_key

chmod 600 deploy_key
eval `ssh-agent -s`
#ssh-add -K deploy_key
