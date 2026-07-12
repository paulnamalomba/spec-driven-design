# Setting Up SSH Access Over the Public Internet on Linux

This guide walks you through configuring your Linux machine to accept secure shell (SSH) connections from outside your local network (over a public IP).

> [!WARNING]
> Exposing SSH (port 22) directly to the public internet makes your machine a target for automated brute-force attacks. **Follow the security recommendations at the end of this guide** to keep your machine secure.

---

## Step 1: Install and Enable OpenSSH Server

First, ensure that the SSH server is installed and running on your Linux machine.

### On Ubuntu / Debian / Mint

```bash
sudo apt update
sudo apt install openssh-server -y
sudo systemctl enable --now ssh
```

### On CentOS / RHEL / Fedora / Rocky Linux

```bash
sudo dnf install openssh-server -y
sudo systemctl enable --now sshd
```./

### On Arch Linux

```bash
sudo pacman -S openssh --noconfirm
sudo systemctl enable --now sshd
```

To verify the SSH service is running:

```bash
sudo systemctl status sshd
```

---

## Step 2: Configure the Local Firewall on Linux

You must allow incoming SSH traffic through your local Linux firewall.

### Using UFW (Uncomplicated Firewall - default on Ubuntu)

```bash
sudo ufw allow ssh
sudo ufw enable
```

*Note: If you plan to use a custom port (e.g., 2222), run `sudo ufw allow 2222/tcp` instead.*

### Using firewalld (default on RHEL/Fedora)

```bash
sudo firewall-cmd --add-service=ssh --permanent
sudo firewall-cmd --reload
```

---

## Step 3: Find Your Local and Public IP Addresses

You will need two IP addresses:

1. **Your Local IP Address**: The address of your Linux machine on your home network (e.g., `192.168.1.15`).
   - Find it by running:

     ```bash
     hostname -I
     ```

2. **Your Public IP Address**: The address assigned to your router by your Internet Service Provider (ISP).
   - Find it by running:

     ```bash
     curl icanhazip.com
     ```

---

## Step 4: Configure Port Forwarding on Your Router

Since your Linux machine sits behind your router's firewall, your router needs to know where to send incoming SSH traffic.

1. Log into your router’s admin interface. (Usually accessible via a web browser at `192.168.1.1` or `192.168.0.1`—check the label on your physical router).
2. Find the **Port Forwarding**, **Virtual Server**, or **Port Mapping** section.
3. Add a new port forwarding rule:
   - **Service Name**: SSH (or custom)
   - **Protocol**: TCP
   - **Internal/Local Port**: `22` (the standard SSH port)
   - **Internal/Local IP Address**: Enter your Linux machine's **Local IP** from Step 3.
   - **External/Public Port**: Use a non-standard port (e.g., `2222` or `4822`). This reduces exposure to basic internet scanners.
4. Save the changes.

---

## Step 5: Test the Connection

From an external network (e.g., a phone hotspot or a remote server), connect using your public IP and your custom external port:

```bash
ssh -p <external-port> username@<public-ip>
```

*Example:*

```bash
ssh -p 4822 kabwe@203.0.113.50
```

---

## Step 6: Security Hardening (Crucial)

Exposing SSH to the public internet requires strong security configurations.

### A. Use SSH Keys Instead of Passwords

1. **Generate a key pair** on the client machine (the computer you are connecting *from*):

   ```bash
   ssh-keygen -t ed25519 -C "your_email@example.com"
   ```

2. **Copy the public key** to your Linux server:

   ```bash
   ssh-copy-id -p <external-port> username@<public-ip>
   ```

3. **Disable password login** on your Linux machine:
   - Open `/etc/ssh/sshd_config` (requires `sudo` privileges):

     ```bash
     sudo nano /etc/ssh/sshd_config
     ```

   - Find or add the line `PasswordAuthentication` and set it to:

     ```text
     PasswordAuthentication no
     ```

   - Make sure `PubkeyAuthentication yes` is set as well.
   - Save and exit (`Ctrl+O`, `Enter`, `Ctrl+X`).
4. **Restart the SSH service** to apply changes:

   ```bash
   sudo systemctl restart ssh   # Ubuntu/Debian
   # OR
   sudo systemctl restart sshd  # RHEL/Arch
   ```

### B. Install Fail2ban

Fail2ban automatically bans IPs that show malicious behavior (such as too many failed login attempts).

- **Ubuntu/Debian**:

  ```bash
  sudo apt install fail2ban -y
  sudo systemctl enable --now fail2ban
  ```

- **RHEL/CentOS**:

  ```bash
  sudo dnf install epel-release -y
  sudo dnf install fail2ban -y
  sudo systemctl enable --now fail2ban
  ```
