
# Getting Started with AWS CLI 

This guide will help you set up and use the AWS Command Line Interface (CLI) on your **Mac or Windows** computer with a new AWS Free Tier account. You'll learn how to install the CLI, configure authentication, create users/roles, and run basic commands.

---

## 1. Prerequisites
- A Mac (macOS) or Windows computer
- An AWS Free Tier account ([Sign up here](https://aws.amazon.com/free/))
- Basic familiarity with the Terminal (Mac) or Command Prompt/PowerShell (Windows)

---

## 2. Install AWS CLI

### On Mac

#### Using Homebrew (Recommended)
1. Open Terminal.
2. Run:
   ```sh
   brew install awscli
   ```
3. Verify installation:
   ```sh
   aws --version
   ```

#### Alternative: Using pip
If you use Python and pip:
```sh
pip install awscli --upgrade --user
```

### On Windows

#### Using the MSI Installer (Recommended)
1. Download the [AWS CLI MSI installer for Windows](https://awscli.amazonaws.com/AWSCLIV2.msi).
2. Run the installer and follow the prompts.
3. Open **Command Prompt** or **PowerShell** and verify installation:
   ```cmd
   aws --version
   ```

#### Alternative: Using pip (if Python is installed)
```cmd
pip install awscli --upgrade --user
```

---

## 3. Set Up AWS CLI Authentication

### Step 1: Create an IAM User
1. Log in to the [AWS Console](https://console.aws.amazon.com/).
2. Go to **IAM** (Identity and Access Management).
3. Click **Users** > **Add users**.
4. Enter a username (e.g., `cli-user`).
5. Select **Access key - Programmatic access**.
6. Click **Next: Permissions**.
7. Attach existing policies (e.g., `AdministratorAccess` for full access, or more restrictive policies for security).
8. Click **Next** and **Create user**.
9. Download or copy the **Access Key ID** and **Secret Access Key** (save these securely!).

### Step 2: Configure AWS CLI
In Terminal (Mac) or Command Prompt/PowerShell (Windows), run:
```sh
aws configure
```
Enter:
- **AWS Access Key ID**: (from above)
- **AWS Secret Access Key**: (from above)
- **Default region name**: (e.g., `us-east-1`)
- **Default output format**: (e.g., `json`)

This creates a `default` profile. To create a **named profile** instead (recommended when working with multiple accounts):
```sh
aws configure --profile my-profile
```

### Step 3: Manage Local Profiles

**List all configured profiles:**
```sh
aws configure list-profiles
```

**View the active configuration for a profile:**
```sh
aws configure list                        # default profile
aws configure list --profile my-profile  # named profile
```

**View the raw credentials and config files:**
```sh
cat ~/.aws/credentials   # stores access keys
cat ~/.aws/config        # stores region, output format, and profile settings
```

**Use a named profile for a single command:**
```sh
aws s3 ls --profile my-profile
```

**Set a named profile as the default for your current shell session:**
```sh
export AWS_PROFILE=my-profile   # Mac/Linux
$env:AWS_PROFILE="my-profile"  # Windows PowerShell
```

**Verify which identity is currently active:**
```sh
aws sts get-caller-identity
aws sts get-caller-identity --profile my-profile
```
This returns the `Account`, `UserId`, and `Arn` — a quick sanity check that you are authenticated as the right user.

---

## 4. (Optional) Using IAM Roles
Roles are typically used for EC2 or cross-account access. For most CLI use, an IAM user is sufficient. If you need to assume a role:
```sh
aws sts assume-role --role-arn arn:aws:iam::ACCOUNT_ID:role/ROLE_NAME --role-session-name session1
```
This returns temporary credentials you can export as environment variables.

---

## 5. Run Basic AWS CLI Commands


### List S3 Buckets
```sh
aws s3 ls
```

### List EC2 Instances
```sh
aws ec2 describe-instances
```

### Check IAM User Info
```sh
aws iam get-user
```

### Help for Any Command
```sh
aws help
aws s3 help
```

*All commands work the same on Mac (Terminal) and Windows (Command Prompt/PowerShell) as long as `aws` is in your PATH.*

---

## 6. Security Tips
- **Never share your secret keys.**
- Use IAM users with least privilege.
- Rotate your keys regularly.
- Consider using [AWS Vault](https://github.com/99designs/aws-vault) or [awsume](https://github.com/trek10inc/awsume) for secure credential management.

---

## 7. Resources
- [AWS CLI Official Docs](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-welcome.html)
- [IAM Best Practices](https://docs.aws.amazon.com/IAM/latest/UserGuide/best-practices.html)
- [AWS Free Tier](https://aws.amazon.com/free/)