# Getting Started with AWS EC2 (Ubuntu Linux)

This guide provides basic setup instructions for launching, connecting to, and configuring an AWS EC2 Ubuntu instance for cloud data engineering labs.

---

## 1. Connecting to Your EC2 Instance via SSH

After launching an EC2 Ubuntu instance in the AWS Console and downloading your `.pem` key pair:

### On macOS / Linux / WSL:
1. Navigate to the folder containing your downloaded key (e.g., `~/Downloads`):
   ```bash
   cd ~/Downloads
   ```
2. Restrict permissions on the private key file (SSH will reject unshielded keys):
   ```bash
   chmod 400 your-key.pem
   ```
3. Connect using SSH and the instance's Public IPv4 address or DNS:
   ```bash
   ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
   ```

### On Windows (Native PowerShell):
Modern Windows 10/11 includes OpenSSH client by default:
```powershell
ssh -i your-key.pem ubuntu@<EC2-PUBLIC-IP>
```

---

## 2. Initial Server Configuration & Python Setup

Once connected to your Ubuntu instance, configure system packages and Python:

```bash
# 1. Update the APT package repository index
sudo apt update && sudo apt upgrade -y

# 2. Check the pre-installed Python version
python3 --version

# 3. Install pip and the virtual environment module
sudo apt install -y python3-pip python3-venv

# 4. Create and activate a dedicated virtual environment
python3 -m venv .venv
source .venv/bin/activate

# 5. Upgrade pip inside the virtual environment
pip install --upgrade pip

# 6. Install required libraries
pip install requests pandas boto3
```

---

## 3. Important Cloud Hygiene & Cost Safety

> [!CAUTION]
> **Avoid Unnecessary AWS Charges:**
> - When you are finished working, return to the AWS Management Console and **Stop** (or **Terminate**) your EC2 instance.
> - Stopping the instance stops compute charges (though small EBS storage charges remain until termination).
> - Never commit your `.pem` private key files or AWS credentials to GitHub!