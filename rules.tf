resource "okta_group_rule" "department" {
  for_each = local.department_groups

  name              = "Rule-Dept-${each.key}"
  status            = "ACTIVE"
  group_assignments = [okta_group.department[each.key].id]
  expression_type   = "urn:okta:expression:1.0"
  expression_value  = "user.department==\"${each.key}\""
}
