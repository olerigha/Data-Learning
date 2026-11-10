---
course: CDE
week: 1
source: "[[Week1-Introduction.pdf]]"
status: new
tags: [generated]
---
# Infrastructure as Code
**In one line:** Define networks, VMs and load balancers in versioned files, and let a tool build them, instead of clicking through a console.

**In plain words:** Clicking around the AWS console is hard to repeat and easy to get wrong. With Infrastructure as Code (IaC) you write down what you want, keep that file in Git like any other code (the DevOps way), and a tool deploys it. Every environment comes out the same, changes are reviewed, and nothing quietly drifts away from the plan.

**Terms**
| Term | Means |
|---|---|
| IaC | Infrastructure as Code |
| DevOps | development and operations working as one, with automation |
| Configuration drift | the real setup slowly stops matching what was intended |
| Terraform / CloudFormation | declarative IaC tools (multi-cloud / AWS-only) |
| Chef / Puppet / Ansible / SaltStack | configuration-management tools |

**Key points**
- Benefits (from the slide): aligns dev and ops, cuts cost, faster deployments, fewer errors, consistent infrastructure, no configuration drift.
- Defines networks, virtual machines, load balancers and connection topology.
- Easy cleanup also helps cloud cost.

**Memorize vs. look up:** Memorize the idea and three benefits. Look up tool syntax.

Related: [[Cloud Economics and Elasticity]], [[Well-Architected Framework]], [[Cloud Cost Management]]
