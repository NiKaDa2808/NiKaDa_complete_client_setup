#!/bin/bash
echo "🚀 Installing CyberAI Agent from GitHub..."

# 💡 Detect OS and install required packages
if [ -x "$(command -v apt)" ]; then
    echo "📦 Detected apt-based system"
    apt update && apt install -y python3-pip wget unzip git
elif [ -x "$(command -v dnf)" ]; then
    echo "📦 Detected dnf-based system"
    dnf install -y python3-pip wget unzip git
elif [ -x "$(command -v yum)" ]; then
    echo "📦 Detected yum-based system"
    yum install -y python3-pip wget unzip git
else
    echo "❌ Unsupported OS: can't find apt, dnf, or yum"
    exit 1
fi

# 🧪 Install required Python libraries
pip3 install -r requirements.txt --quiet

# 👤 Read login
read -p "Client Email: " EMAIL
read -s -p "Password: " PASSWORD
echo

# 📁 Setup agent directory
mkdir -p /opt/CyberAI-Client
cp agent.py update_client.sh version.txt requirements.txt /opt/CyberAI-Client/

# 🔁 Create systemd service
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
Environment=CYBERAI_EMAIL=$EMAIL
Environment=CYBERAI_PASSWORD=$PASSWORD

[Install]
WantedBy=multi-user.target
EOF

# 🔄 Reload + Start
chmod +x /opt/CyberAI-Client/agent.py
systemctl daemon-reexec
systemctl daemon-reload
systemctl enable cyberai-agent
systemctl restart cyberai-agent

echo "✅ CyberAI Agent installed and running!"