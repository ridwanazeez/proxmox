#!/bin/ash

# Install nano and openssh
apk add nano
apk add openssh

# Add sshd to runlevel and start it
rc-update add sshd
service sshd start

# Download custom ssh_config
curl -O https://raw.githubusercontent.com/ridwanazeez/proxmox/master/setup_alpine_linux/sshd_config

# Edit SSH configuration to allow SSH root login
ssh_config="/etc/ssh/sshd_config"
custom_config="sshd_config"

# Backup the original sshd_config file
cp "$ssh_config" "$ssh_config.backup"

# Replace the contents of sshd_config with your custom configuration
cat "$custom_config" > "$ssh_config"

# Restart sshd
service sshd restart

# Install docker, docker-compose, and openrc
apk add --update docker docker-compose openrc

# Add docker to boot runlevel and start it
rc-update add docker boot
service docker start

# Install zsh, wget, and git
apk add zsh wget git

# Change default shell to zsh
sed -i -e "s/bin\/ash/bin\/zsh/" /etc/passwd

# Reload terminal
omz reload

# Install Oh My Zsh
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)"

# Create a Docker volume for Portainer data
docker volume create portainer_data

# Run Portainer container
docker run -d -p 8000:8000 -p 9443:9443 --name portainer --restart=always -v /var/run/docker.sock:/var/run/docker.sock -v portainer_data:/data portainer/portainer-ce:latest

# Run Watchtower container to auto-update other containers
docker run -d --name watchtower --volume /var/run/docker.sock:/var/run/docker.sock containrrr/watchtower
