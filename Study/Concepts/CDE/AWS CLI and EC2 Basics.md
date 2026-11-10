---
course: CDE
week: 1
source: "[[AWS-CLI]], [[EC2]]"
status: new
tags: [generated]
---
# AWS CLI and EC2 Basics
**In one line:** Control AWS from your terminal, and rent a Linux server (EC2) that you log into over SSH.

**In plain words:** The AWS CLI lets you run AWS commands from a terminal instead of the website. It needs a user's access keys, which you set once with `aws configure`. EC2 is a virtual computer in AWS's data center. You connect to it with a private key file, install Python, do your work, and then **stop or terminate it** so it stops costing money.

**Terms**
| Term | Means |
|---|---|
| CLI | command-line interface |
| IAM user | an identity in your AWS account with its own permissions |
| Access key ID / secret | the username/password pair the CLI uses |
| Profile | a saved set of credentials + region (`--profile name`) |
| EC2 | Elastic Compute Cloud: rented virtual machines |
| `.pem` key | private key file for SSH login |
| SSH | secure remote login to a server |
| Stop vs Terminate | stop = paused (small storage charge remains); terminate = deleted |

**Key points**
- `aws configure` sets keys, default region (e.g. `us-east-1`) and output format.
  In words: save who you are and where to work by default.
- `aws sts get-caller-identity`
  In words: "who am I logged in as?", a quick sanity check.
- `chmod 400 key.pem` then `ssh -i key.pem ubuntu@<public-ip>`
  In words: lock down the key file, then log into the server with it.
- Never commit `.pem` files or AWS keys to GitHub.

**Memorize vs. look up:** Memorize stop vs terminate and "never commit keys". Look up exact commands.

Related: [[VPC and IAM Least Privilege]], [[Cloud Service Models]], [[Infrastructure as Code]]
