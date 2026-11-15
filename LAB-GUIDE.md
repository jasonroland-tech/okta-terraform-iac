# Lab guide: Okta managed with Terraform

**Time:** about 90 minutes. **Cost:** free.
**Why this lab:** 9 of 18 IAM job posts I read want Terraform, and Tenable, Hadrian and Adyen use it to run Okta itself.

📸 = take a screenshot for the README. Redact your org URL and client ID.

## Part 1: Set up (30 min)

**1. Get a free Okta org.** Sign up at developer.okta.com (Integrator Free Plan). Note your org URL, for example `integrator-1234567.okta.com`.
*Why:* never test automation in your work tenant.

**2. Create the Terraform app.** Admin console > Applications > Create App Integration > **API Services** > name it `Terraform`.
- General tab > Client Credentials > Edit > **Public key / Private key** > Add key > Generate new key > copy the **PEM** private key and the **KID**. Save.
- Uncheck **Require DPoP header**, then Save.
- Okta API Scopes tab > Grant `okta.users.manage`, `okta.groups.manage`, `okta.apps.manage`.
- Admin roles tab > Edit assignments > **Super Administrator** (lab only; in production use a custom role).

*Why:* Terraform signs in as an app with a key, not as you with a password. That's how real teams do it, and it's a non-human identity you can show you secured. 📸 the granted scopes.

**3. Save the key outside the repo.** On your Mac:
```bash
mkdir -p ~/.okta && nano ~/.okta/terraform-key.pem   # paste the PEM, Ctrl+O, Enter, Ctrl+X
chmod 600 ~/.okta/terraform-key.pem
```

**4. Clone the repo and set your environment.** In VS Code: Terminal > New Terminal.
```bash
cd ~/Documents/GitHub && git clone https://github.com/jasonroland-tech/okta-terraform-iac.git && cd okta-terraform-iac
export OKTA_ORG_NAME="integrator-1234567"        # your prefix
export OKTA_BASE_URL="okta.com"
export OKTA_API_CLIENT_ID="paste-client-id"
export OKTA_API_PRIVATE_KEY_ID="paste-kid"
export OKTA_API_PRIVATE_KEY="$HOME/.okta/terraform-key.pem"
export OKTA_API_SCOPES="okta.users.manage,okta.groups.manage,okta.apps.manage"
```
*Why:* environment variables keep secrets out of Git. Close the terminal and they're gone.

## Part 2: Build it (20 min)

**5. Initialize and preview.**
```bash
terraform init
terraform plan
```
Read the plan: it should add 4 users, 4 groups, 3 rules, 1 membership, 1 app, 1 assignment. Nothing has changed in Okta yet. 📸 the `Plan:` line.

**6. Apply.**
```bash
terraform apply    # type yes
```
In Okta, open Directory > Groups > `Dept-Engineering`. Ava and Cara are in it because of the rule, not because anyone clicked. 📸 the group members. 📸 Rules tab.

## Part 3: Joiner, mover, leaver as code (25 min)

**7. Joiner.** In `variables.tf`, add a user inside `default = {`:
```hcl
    "erin.fox" = {
      first_name = "Erin"
      last_name  = "Fox"
      department = "Engineering"
      title      = "QA Engineer"
    }
```
Run `terraform apply`. Erin gets `Dept-Engineering` and the GitHub tile automatically. 📸 Erin's Applications tab.

**8. Mover.** Change Ben's `department` from `Clinical` to `Engineering`. Run `terraform plan` (1 to change), then apply. Ben moves groups and gains GitHub. 📸 the plan showing `~ department`.

**9. Leaver.** Add `status = "SUSPENDED"` to Dan's entry and apply. Dan can't sign in, but his account and history stay for audit. 📸 Dan's status.

**10. Catch drift.** In the Okta console, manually add Dan to `Role-IAM-Admins`. Then run `terraform plan`: Terraform flags the change because it wasn't in code. Apply to remove it. 📸 the plan output.
*Why:* this is the strongest point in your Loom. Someone changing access by hand gets caught and reverted.

## Part 4: Publish (15 min)

**11. Format and push.**
```bash
terraform fmt
git add . && git commit -m "Joiner, mover, leaver and drift tests" && git push
```
On GitHub, the Actions tab runs format and validate checks. 📸 the green check.

**12. Fill in the README.** Paste your screenshots into `screenshots/` and update the Results table.

Leave the org running. Lab 2 and Lab 4 use the same users.
