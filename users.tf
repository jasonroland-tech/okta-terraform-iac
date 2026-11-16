resource "okta_user" "workforce" {
  for_each = var.users

  first_name = each.value.first_name
  last_name  = each.value.last_name
  login      = "${each.key}@${var.email_domain}"
  email      = "${each.key}@${var.email_domain}"
  department = each.value.department
  title      = each.value.title

  # Offboarding is a status change, not a delete, so the account and its audit trail survive.
  status = each.value.status

  # Guardrail: any plan that would delete a user fails instead of running.
  # Deleting a user loses their ID, MFA and app links, and Git can't bring those back.
  # To truly delete someone, remove this guard in a reviewed pull request first.
  lifecycle {
    prevent_destroy = true
  }
}
