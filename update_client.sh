#!/bin/bash
REMOTE_ZIP="https://github.com/NiKaDa2808/NiKaDa-client-setup/archive/refs/heads/main.zip"
TMP_DIR="/tmp/cyberai_update"
CURRENT_DIR="/opt/CyberAI-Client"

echo "🌀 Checking for update..."

mkdir -p $TMP_DIR
cd $TMP_DIR
wget -q $REMOTE_ZIP -O update.zip
unzip -q update.zip
cd NiKaDa-client-setup-main

remote_version=$(cat version.txt)
local_version=$(cat $CURRENT_DIR/version.txt)

if [ "$remote_version" != "$local_version" ]; then
    echo "⬆️ New version found: $remote_version (current: $local_version)"
    cp agent.py update_client.sh version.txt $CURRENT_DIR/
    chmod +x $CURRENT_DIR/agent.py
    systemctl restart cyberai-agent
    echo "✅ Updated to version $remote_version"
else
    echo "✔️ Already up to date ($local_version)"
fi

rm -rf $TMP_DIR