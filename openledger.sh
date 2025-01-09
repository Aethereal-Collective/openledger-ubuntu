#!/bin/bash

curl -s https://raw.githubusercontent.com/aethjuice/aethjuice/main/logo.sh | bash
sleep 3

echo "Updating and upgrading system packages..."
sudo apt update && sudo apt upgrade -y

echo "Configuring Firewall..."
sudo ufw allow 22
sudo ufw allow 3389
sudo ufw reload
echo "Port 22 (SSH) and Port 3389 (RDP) have been configured."

echo "Installing XFCE desktop environment..."
sudo apt install -y xfce4 xfce4-goodies
if [ $? -eq 0 ]; then
    echo "XFCE installation successful."
else
    echo "XFCE installation failed."
    exit 1
fi

echo "Installing LightDM display manager..."
sudo apt install -y lightdm
if [ $? -eq 0 ]; then
    echo "LightDM installation successful."
else
    echo "LightDM installation failed."
    exit 1
fi

echo "Configuring LightDM as the default display manager..."
sudo systemctl enable lightdm
sudo systemctl start lightdm

echo "Installing XRDP for remote desktop access..."
sudo apt install -y xrdp
if [ $? -eq 0 ]; then
    echo "XRDP installation successful."
else
    echo "XRDP installation failed."
    exit 1
fi

echo "Configuring XRDP to use XFCE..."
echo xfce4-session >~/.xsession
sudo systemctl enable xrdp
sudo systemctl restart xrdp
sudo adduser xrdp ssl-cert
sudo systemctl status xrdp --no-pager

echo "Firewall status:"
sudo ufw status verbose

echo "Setting up Docker environment..."
echo "Removing older Docker versions..."
sudo apt-get remove -y docker.io docker-doc docker-compose docker-compose-v2 podman-docker containerd runc

echo "Installing prerequisites..."
sudo apt-get install -y ca-certificates curl gnupg

echo "Setting up Docker repository..."
sudo install -m 0755 -d /etc/apt/keyrings
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg -o /etc/apt/keyrings/docker.asc
sudo chmod a+r /etc/apt/keyrings/docker.asc
echo \
  "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.asc] https://download.docker.com/linux/ubuntu \
  $(. /etc/os-release && echo \"$VERSION_CODENAME\") stable" | \
  sudo tee /etc/apt/sources.list.d/docker.list > /dev/null

echo "Installing Docker..."
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
echo "Docker installation complete."

echo "Downloading and installing OpenLedger..."
wget https://cdn.openledger.xyz/openledger-node-1.0.0-linux.zip
sudo apt install -y unzip
unzip openledger-node-1.0.0-linux.zip
sudo dpkg -i openledger-node-1.0.0.deb

echo "Setup complete! OpenLedger are ready. You can now use Remote Desktop Connection to access the server."
