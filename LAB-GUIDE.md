# Lab guide: Okta managed with Terraform

**Time:** 45 min. **Cost:** free.
**Skills:** Terraform (infrastructure as code), non-human identity, group rules, joiner/mover/leaver, drift detection.

📸 = screenshot for the README. Redact your org URL and client ID.

## Before you start

**Accounts**
- [ ] **Okta Integrator Free Plan org**: sign up at developer.okta.com/signup with your personal email (not LogicGate). Set your password and MFA from the activation email.
- [ ] **GitHub**: you already have `jasonroland-tech`.

**Software on your Mac** (run each check in Terminal; install only what's missing)
| Tool | Check | Install if missing |
| --- | --- | --- |
| Homebrew | `brew --version` | `/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"` |
| Terraform | `terraform -version` | `brew tap hashicorp/tap && brew install hashicorp/tap/terraform` |
| Git | `git --version` | `xcode-select --install` |
| VS Code | open it | code.visualstudio.com |
| VS Code extension (optional) | | HashiCorp Terraform (syntax colors for `.tf` files) |

## Setup (15 min)

**1. Open your Okta org.** Sign in to the Integrator Free Plan org from "Before you start". Your org name is the **address bar** prefix, e.g. `integrator-1234567` (drop `-admin`). The name under your profile in the top right is only a display name; using it causes `invalid_client`.
*Why:* never test automation in your work tenant.

**2. Create the Terraform app.** Admin console > Applications > Create App Integration > **API Services** > name `Terraform`.
- Client Credentials > Edit > **Public key / Private key** > Add key > Generate new key > copy the **PEM** and the **KID** > uncheck **Require DPoP header** > Save.
- Okta API Scopes tab > Grant `okta.users.manage`, `okta.groups.manage`, `okta.apps.manage`, `okta.policies.read` (apps need it to attach the default sign in policy). 📸
- Admin roles tab > **Super Administrator** (lab only).

*Why:* Terraform signs in as an app with a key, not as you with a password.

**3. Key and environment.** In VS Code's terminal:
```bash
mkdir -p ~/.okta && nano ~/.okta/terraform-key.pem      # paste PEM, Ctrl+O, Enter, Ctrl+X
chmod 600 ~/.okta/terraform-key.pem
cd ~/Documents/GitHub && git clone https://github.com/jasonroland-tech/okta-terraform-iac.git && cd okta-terraform-iac
export OKTA_ORG_NAME="integrator-1234567" OKTA_BASE_URL="okta.com"   # from the ADDRESS BAR, not the display name
export OKTA_API_CLIENT_ID="paste-client-id" OKTA_API_PRIVATE_KEY_ID="paste-kid"
export OKTA_API_PRIVATE_KEY="$HOME/.okta/terraform-key.pem"
export OKTA_API_SCOPES="okta.users.manage,okta.groups.manage,okta.apps.manage,okta.policies.read"
```
*Why:* secrets stay out of Git and disappear when the terminal closes.

## Build (10 min)

> **If apply fails with `empty access token`:** run `TF_LOG=DEBUG TF_LOG_PATH=tf-debug.log terraform apply`, then `grep -i -E "errorSummary|error_description" tf-debug.log | head -3`, and delete the log after. Common causes: wrong org name (`invalid_client`), a Mac clock a few seconds fast (`expiration too far into the future`, fix with `sudo sntp -sS time.apple.com`), or a PEM that doesn't match the KID.


**4. Plan, then apply.**
```bash
terraform init && terraform plan
terraform apply      # type yes
```
The plan shows what will change before anything does. 📸 the `Plan:` line.
In Okta, open `Dept-Engineering`: Ava and Cara got in through the rule, nobody clicked. 📸

## Lifecycle as code (15 min)

**5. Joiner.** In `variables.tf`, add inside `default = {`:
```hcl
    "erin.fox" = { first_name = "Erin", last_name = "Fox", department = "Engineering", title = "QA Engineer" }
```
`terraform apply`. Erin gets the group and the GitHub tile automatically.

**6. Mover.** Change Ben's `department` to `"Engineering"`. `terraform plan` shows `~ department` (update in place). Apply. 📸 the plan.

**7. Leaver.** Add `status = "DEPROVISIONED"` to Dan and apply. That is Okta's **deactivate**: all access ends, but his account and history stay for audit. (Users created without a password sit in **Provisioned / Pending user action**, and Okta only allows suspend on fully active users, so deactivate is the right offboarding step here.)

**8. Catch drift.** In the Okta console, add **Ava** to `Role-IAM-Admins` by hand. Run `terraform plan`: it flags the change. Apply to revert it. 📸
*Why:* this is your Loom headline. Access changed outside the process gets caught and undone.

**9. Block accidental deletes.** Run `git pull` to get the guardrail now in `users.tf`:
```hcl
  lifecycle {
    prevent_destroy = true
  }
```
Run `terraform plan`: **No changes** (the guard is a rule for Terraform, not a change in Okta). Now delete Ava's line from `variables.tf`, save, and run `terraform plan` again. It fails with **Instance cannot be destroyed**. 📸 Put Ava's line back (Cmd+Z, save) and plan again: **No changes**.
*Why:* deleting a user loses their ID, MFA and app links, and Git can only rebuild them as new people. Offboarding is deactivate; deleting needs the guard removed in a reviewed change.

**10. Push.**
```bash
terraform fmt && git add . && git commit -m "Lifecycle and drift tests" && git push
```
The GitHub Actions check runs automatically. 📸 the green check if you have time.

Keep the org. Labs 2 and 5 reuse it.
