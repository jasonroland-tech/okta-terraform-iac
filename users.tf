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
}
