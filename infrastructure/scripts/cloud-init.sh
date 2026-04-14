#cloud-config
users:
  - name: admin
    groups: [users, sudo]
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    ssh_authorized_keys:
      - ${ssh_key}

packages:
  - fail2ban
  - ufw
  - curl
  - debian-keyring
  - debian-archive-keyring
  - apt-transport-https

package_update: true
package_upgrade: true

write_files:
  - path: /etc/ssh/sshd_config.d/ssh-hardening.conf
    content: |
      PermitRootLogin no
      PasswordAuthentication no
      Port 2222
      KbdInteractiveAuthentication no
      ChallengeResponseAuthentication no
      MaxAuthTries 4
      AllowTcpForwarding no
      X11Forwarding no
      AllowAgentForwarding no
      AuthorizedKeysFile .ssh/authorized_keys
      AllowUsers admin
      
  # 1. Provision the Caddyfile
  - path: /etc/caddy/Caddyfile
    content: |
      ${domain_name} {
          root * /var/www/hugo-site
          file_server
          encode gzip zstd
          
          handle_errors {
              @404 {
                  expression {http.error.status_code} == 404
              }
              rewrite @404 /404.html
              file_server
          }
      }

runcmd:
  # SSH and Fail2ban setup
  - printf "[sshd]\nenabled = true\nport = ssh, 2222\nbanaction = iptables-multiport" > /etc/fail2ban/jail.local
  - systemctl enable fail2ban
  - systemctl restart fail2ban
  
  # UFW Setup (Added port 80 for Caddy HTTP->HTTPS redirects)
  - ufw allow 2222/tcp
  - ufw allow 80/tcp
  - ufw allow 443/tcp
  - ufw --force enable

  # 2. Install Caddy via official repository
  - curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/gpg.key' | gpg --dearmor -o /usr/share/keyrings/caddy-stable-archive-keyring.gpg
  - curl -1sLf 'https://dl.cloudsmith.io/public/caddy/stable/debian.deb.txt' | tee /etc/apt/sources.list.d/caddy-stable.list
  - apt-get update
  - apt-get install -y caddy

  # 3. Set up the web root directory for the Hugo site and give 'admin' ownership
  - mkdir -p /var/www/hugo-site
  - chown -R admin:admin /var/www/hugo-site

  # Apply the Caddyfile
  - systemctl restart caddy
  - systemctl enable caddy

  # 4. Trigger the GitHub Action in the Hugo Repository
  # The | symbol preserves the multiline formatting of the curl command
  - |
    curl -X POST \
      -H "Accept: application/vnd.github+json" \
      -H "Authorization: Bearer ${github_token}" \
      -H "X-GitHub-Api-Version: 2022-11-28" \
      https://api.github.com/repos/${github_username}/${hugo_repo_name}/dispatches \
      -d '{"event_type": "infra_redeployed"}'

power_state:
  mode: reboot
