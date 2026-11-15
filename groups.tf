locals {
  # Department groups are filled automatically by group rules (attribute based access).
  department_groups = {
    Engineering = "Everyone whose Okta department is Engineering. Managed by a group rule."
    Clinical    = "Everyone whose Okta department is Clinical. Managed by a group rule."
    Finance     = "Everyone whose Okta department is Finance. Managed by a group rule."
  }
}

resource "okta_group" "department" {
  for_each = local.department_groups

  name        = "Dept-${each.key}"
  description = each.value
}

# Small, high trust group managed by direct membership instead of a rule.
resource "okta_group" "iam_admins" {
  name        = "Role-IAM-Admins"
  description = "IAM team. Membership changes only through a reviewed pull request."
}

resource "okta_group_memberships" "iam_admins" {
  group_id = okta_group.iam_admins.id
  users    = [for u in var.iam_admins : okta_user.workforce[u].id]

  # Track every member, so someone added by hand in the console shows up as drift.
  track_all_users = true
}
