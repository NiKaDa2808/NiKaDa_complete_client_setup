#!/bin/bash
echo "🚀 Installing CyberAI Agent from GitHub..."
if [ -x "$(command -v apt)" ]; then
    echo "📦 Detected apt-based system"
    apt update && apt install -y python3-pip wget unzip
elif [ -x "$(command -v dnf)" ]; then
    echo "📦 Detected dnf-based system"
    dnf install -y python3-pip wget unzip
elif [ -x "$(command -v yum)" ]; then
    echo "📦 Detected yum-based system"
    yum install -y python3-pip wget unzip
else
    echo "❌ Unsupported OS: can't find apt, dnf, or yum"
    exit 1
fi
cd "$(dirname "$0")"
client_folder=$(find . -maxdepth 1 -type d -name "CyberAI-Client*" ! -name "." | head -n 1)
if [ -z "$client_folder" ]; then
  echo "❌ Could not find extracted CyberAI-Client folder!"
  exit 1
fi
timestamp=$(date +"%Y-%m-%d_%H-%M-%S")
target_dir="CyberAI-Client_$timestamp"
mkdir "$target_dir"
mv "$client_folder"/agent.py "$client_folder"/install_client.sh "$client_folder"/update_client.sh "$client_folder"/version.txt "$target_dir"
cd "$target_dir"
read -p "Client Email: " EMAIL
read -s -p "Password: " PASSWORD
echo
mkdir -p /opt/CyberAI-Client
cp agent.py update_client.sh version.txt /opt/CyberAI-Client/
cat <<EOF > /etc/systemd/system/cyberai-agent.service
[Unit]
Description=CyberAI Shield Agent
After=network.target
[Service]
User=root
WorkingDirectory=/opt/CyberAI-Client
ExecStart=/usr/bin/python3 /opt/CyberAI-Client/agent.py
Restart=always
RestartSec=5
StartLimitBurst=3
StartLimitInterval=30
Environment=CYBERAI_EMAIL=$EMAIL
Environment=CYBERAI_PASSWORD=$PASSWORD
[Install]
WantedBy=multi-user.target
EOF
chmod +x /opt/CyberAI-Client/agent.py
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable cyberai-agent
systemctl restart cyberai-agent
echo "✅ CyberAI Agent installed and running!"
