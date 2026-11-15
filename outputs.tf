output "department_group_ids" {
  description = "Okta IDs of the department groups"
  value       = { for k, g in okta_group.department : k => g.id }
}

output "user_logins" {
  description = "Login and status for every managed user"
  value       = { for k, u in okta_user.workforce : u.login => u.status }
}
