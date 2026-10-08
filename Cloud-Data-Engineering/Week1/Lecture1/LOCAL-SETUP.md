# Local Development Environment Setup Guide: Mac & Windows

This guide walks you through setting up a professional local data engineering environment on **macOS** or **Windows**. By the end of this guide, you will have a configured terminal, package manager, Python 3.12 environment (both `venv` and `conda`), Git, and VS Code ready for all course exercises.

---

## Table of Contents

1. [Terminal Setup (Mac & Windows)](#1-terminal-setup)
2. [Package Managers (Homebrew & Winget)](#2-package-managers)
3. [Python Installation & Pip](#3-python-installation--pip)
4. [Virtual Environments with `venv` (Course Standard)](#4-virtual-environments-with-venv-course-standard)
5. [Anaconda & Miniconda Alternative](#5-anaconda--miniconda-alternative)
6. [Git & GitHub Setup](#6-git--github-setup)
7. [Visual Studio Code Configuration](#7-visual-studio-code-configuration)
8. [Common Troubleshooting & Gotchas](#8-common-troubleshooting--gotchas)

---

## 1. Terminal Setup

The terminal is the primary interface for cloud data engineers to run scripts, interact with cloud CLIs, build containers, and manage version control.

### macOS

macOS includes a built-in terminal that defaults to `zsh`.

- **Built-in Terminal:** Located in `/Applications/Utilities/Terminal.app`.
- **Recommended Alternative — iTerm2:** A feature-rich replacement for Terminal offering split panes, robust search, and customized color themes.
  - Install via Homebrew: `brew install --cask iterm2`
- **Verify your default shell:**
  ```bash
  echo $SHELL
  # Output should be: /bin/zsh
  ```

### Windows

Windows developers have two great options: **PowerShell 7 via Windows Terminal** or **WSL2 (Windows Subsystem for Linux)**.

#### Option A: Windows Terminal + PowerShell (Native Windows)
- Install **Windows Terminal** from the Microsoft Store or via Winget:
  ```cmd
  winget install Microsoft.WindowsTerminal
  ```
- Windows Terminal allows running PowerShell, Command Prompt, and Linux shells in modern tabs with full Unicode and UTF-8 support.

#### Option B: Windows Subsystem for Linux (WSL2 — Strongly Recommended for Data Engineering)
WSL2 runs a real Ubuntu Linux kernel inside Windows. This eliminates cross-platform issues with bash scripts, file permissions, and Docker:
1. Open PowerShell **as Administrator** and run:
   ```powershell
   wsl --install
   ```
2. Restart your computer when prompted.
3. Open "Ubuntu" from your Start Menu, set a Linux username and password, and update packages:
   ```bash
   sudo apt update && sudo apt upgrade -y
   ```

---

## 2. Package Managers

Package managers automate installing, updating, and managing developer tools and runtimes.

### macOS: Homebrew

[Homebrew](https://brew.sh/) is the de facto package manager for macOS.

#### Installation
Open Terminal and run:
```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

#### Crucial Step for Apple Silicon (M1/M2/M3/M4 Macs)
Homebrew installs into `/opt/homebrew` on Apple Silicon. Add it to your shell profile so the `brew` command is found:
```bash
echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile
eval "$(/opt/homebrew/bin/brew shellenv)"
```

#### Verify Homebrew
```bash
brew --version
brew doctor
```

#### Install Essential Course Tools
```bash
brew install git python@3.12 jq tree gh awscli
```

---

### Windows: Winget

Modern Windows 10 and 11 include `winget` (Windows Package Manager) out of the box.

#### Verify Winget
Open PowerShell and run:
```powershell
winget --version
```

#### Install Essential Course Tools
```powershell
winget install Git.Git
winget install Python.Python.3.12
winget install Microsoft.VisualStudioCode
winget install Amazon.AWSCLI
```

---

## 3. Python Installation & Pip

The tested standard for this course is **Python 3.12**.

### Checking Your Python Version

- **macOS / Linux / WSL:**
  ```bash
  python3 --version
  # Should output: Python 3.12.x
  ```
- **Windows (PowerShell):**
  ```powershell
  python --version
  # or
  py --version
  ```

### Understanding `pip`
`pip` is Python's package installer. Always verify `pip` points to your Python 3.12 installation:
```bash
python3 -m pip --version
```

> **Warning for macOS users (PEP 668):**
> Modern macOS and Homebrew prevent installing packages globally via `pip install <package>` (giving an `error: externally-managed-environment`). **Always use a virtual environment** as described in the next section.

---

## 4. Virtual Environments with `venv` (Course Standard)

A virtual environment isolates project dependencies, preventing version conflicts between different courses or projects.

### Step 1: Navigate to the Course Directory
```bash
cd /path/to/CloudDataEngineering/code
```

### Step 2: Create the Virtual Environment
Create a virtual environment named `.venv` in the repository root:

- **macOS / Linux / WSL:**
  ```bash
  python3.12 -m venv .venv
  ```
- **Windows (PowerShell):**
  ```powershell
  py -3.12 -m venv .venv
  # or
  python -m venv .venv
  ```

### Step 3: Activate the Virtual Environment

- **macOS / Linux / WSL (Zsh or Bash):**
  ```bash
  source .venv/bin/activate
  ```
  *(Your terminal prompt will now show `(.venv)` at the beginning).*

- **Windows PowerShell:**
  ```powershell
  .venv\Scripts\Activate.ps1
  ```
  *If you receive a script execution error in PowerShell, run this once to allow local scripts:*
  ```powershell
  Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
  ```

- **Windows Command Prompt (`cmd`):**
  ```cmd
  .venv\Scripts\activate.bat
  ```

### Step 4: Upgrade Pip & Install Course Dependencies
Once the environment is active:
```bash
python -m pip install --upgrade pip
python -m pip install -r requirements.txt
```

### Step 5: Deactivate When Finished
When you want to leave the virtual environment:
```bash
deactivate
```

---

## 5. Anaconda & Miniconda Alternative

Some data engineers prefer **Conda** because it manages both Python packages and low-level C/C++ libraries (such as GDAL, OpenSSL, or BLAS).

### Which Distribution to Choose?
- **Miniconda (Recommended):** A lightweight installer containing only Python and Conda (~100 MB). You install only what you need.
- **Anaconda:** Full distribution with 1,500+ pre-installed data science packages (~3 GB download, 5+ GB disk space). Often bloated for engineering workflows.

### Installing Miniconda

#### macOS
```bash
# Using Homebrew:
brew install --cask miniconda

# Initialize for Zsh:
conda init zsh
```
*Close and reopen your terminal.*

#### Windows
```powershell
# Using Winget:
winget install Anaconda.Miniconda3
```
*After installation, open "Anaconda PowerShell Prompt" from the Start Menu or initialize in your terminal:*
```powershell
conda init powershell
```

### Essential Conda Workflow

#### 1. Prevent Conda's Base Environment from Auto-Activating
By default, Conda activates its `(base)` environment in every new terminal. Disable this to avoid interfering with system tools:
```bash
conda config --set auto_activate_base false
```

#### 2. Create a Dedicated Environment for the Course
```bash
conda create --name cde-312 python=3.12 -y
```

#### 3. Activate the Environment
```bash
conda activate cde-312
```

#### 4. Install Packages Inside the Conda Environment
You can install Conda packages or use `pip` inside the activated Conda environment:
```bash
# Install course requirements:
pip install -r requirements.txt
```

#### 5. Deactivate or Remove
```bash
# Deactivate:
conda deactivate

# To view all environments:
conda env list

# To delete the environment if needed:
conda env remove --name cde-312
```

---

## 6. Git & GitHub Setup

### 1. Verify Git Installation
```bash
git --version
```

### 2. Configure Global Git Identity
Set the name and email that will be attached to your commits (use your university email):
```bash
git config --global user.name "Your Full Name"
git config --global user.email "your_cnetid@uchicago.edu"
git config --global init.defaultBranch main
```

### 3. Handle Cross-Platform Line Endings (CRLF vs. LF)
Windows uses Carriage Return + Line Feed (`\r\n`), while macOS and Linux use Line Feed (`\n`). Configure Git to handle conversions automatically so team members on different OSs don't cause Git diff conflicts:

- **macOS / Linux:**
  ```bash
  git config --global core.autocrlf input
  ```
- **Windows:**
  ```powershell
  git config --global core.autocrlf true
  ```

### 4. Authenticate with GitHub CLI (Recommended)
The fastest and most secure way to authenticate with GitHub is using the GitHub CLI:
```bash
gh auth login
```
Follow the interactive prompts: choose `GitHub.com` &rarr; `HTTPS` &rarr; authenticate via web browser.

---

## 7. Visual Studio Code Configuration

[Visual Studio Code](https://code.visualstudio.com/) is the recommended IDE for this course.

### Recommended Extensions
Search and install these in the VS Code Extensions tab (`Cmd+Shift+X` on Mac, `Ctrl+Shift+X` on Windows):
1. **Python** (by Microsoft) — Linting, debugging, and IntelliSense.
2. **Pylance** (by Microsoft) — Fast type checking and auto-completion.
3. **Jupyter** (by Microsoft) — Notebook execution directly in VS Code.
4. **WSL** (by Microsoft — *Windows only*) — Lets you open Linux folders in VS Code seamlessly.
5. **Docker** (by Microsoft) — Container management for later weeks.
6. **Rainbow CSV** — Syntax highlighting and column alignment for CSV files.

### Selecting Your Virtual Environment in VS Code
To ensure VS Code uses your `.venv` or conda environment:
1. Open the project root folder in VS Code (`code/`).
2. Press `Cmd+Shift+P` (Mac) or `Ctrl+Shift+P` (Windows) to open the Command Palette.
3. Type: `Python: Select Interpreter`.
4. Select the interpreter pointing to `./.venv/bin/python` (or your Conda environment `cde-312`).
5. For Jupyter Notebooks (`.ipynb`), click the kernel selector in the top-right corner of any notebook and choose the same Python environment.

---

## 8. Common Troubleshooting & Gotchas

| Issue / Error | Operating System | Cause | Fix |
|---|---|---|---|
| `zsh: command not found: brew` | macOS (Apple Silicon) | Homebrew bin is not in PATH | Run `echo 'eval "$(/opt/homebrew/bin/brew shellenv)"' >> ~/.zprofile` and restart terminal. |
| `error: externally-managed-environment` | macOS | PEP 668 safety restriction | Do not run `pip` globally. Activate a virtual environment (`source .venv/bin/activate`) first. |
| `cannot be loaded because running scripts is disabled` | Windows PowerShell | Restricted script execution policy | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` in PowerShell. |
| `bash: ./script.sh: /bin/bash^M: bad interpreter` | Windows / WSL | Windows CRLF line endings in shell scripts | Convert script to Unix line endings: `sed -i -e 's/\r$//' script.sh` or toggle `CRLF` to `LF` in the bottom-right status bar of VS Code. |
| `python` launches Microsoft Store | Windows | Windows app execution aliases | In Windows Settings &rarr; Apps &rarr; Advanced app settings &rarr; App execution aliases, turn off `python.exe` and `python3.exe`. |
| Port already in use (e.g., MySQL 3306 or web servers) | Mac & Windows | Previous process still running in background | Mac: `lsof -i :3306` followed by `kill -9 <PID>`. Windows: `netstat -ano \| findstr :3306` followed by `taskkill /F /PID <PID>`. |

---

## Quick Reference Summary

```bash
# Clone the repository
git clone https://github.com/<org>/CloudDataEngineering.git
cd CloudDataEngineering/code

# Create and activate Python virtual environment
python3.12 -m venv .venv
source .venv/bin/activate        # macOS / Linux / WSL
# .venv\Scripts\Activate.ps1    # Windows PowerShell

# Install dependencies
python -m pip install --upgrade pip
python -m pip install -r requirements.txt

# Verify installation
python -c "import pandas, requests, yaml; print('All core packages loaded successfully!')"
```
