variable "email_domain" {
  description = "Domain used for test user logins. Use a domain you do not receive mail on."
  type        = string
  default     = "lakeviewhealth.example"
}

variable "users" {
  description = "Lakeview Health workforce. Add, change or remove an entry to run a joiner, mover or leaver."
  type = map(object({
    first_name = string
    last_name  = string
    department = string
    title      = string
    status     = optional(string, "ACTIVE")
  }))

  default = {
    "ava.adams" = {
      first_name = "Ava"
      last_name  = "Adams"
      department = "Engineering"
      title      = "Software Engineer"
    }
    "ben.cruz" = {
      first_name = "Ben"
      last_name  = "Cruz"
      department = "Clinical"
      title      = "Registered Nurse"
    }
    "cara.diaz" = {
      first_name = "Cara"
      last_name  = "Diaz"
      department = "Engineering"
      title      = "Platform Engineer"
    }
    "dan.evans" = {
      first_name = "Dan"
      last_name  = "Evans"
      department = "Finance"
      title      = "Financial Analyst"
    }
  }

  validation {
    condition = alltrue([
      for u in values(var.users) : contains(["ACTIVE", "SUSPENDED", "DEPROVISIONED"], u.status)
    ])
    error_message = "status must be ACTIVE, SUSPENDED or DEPROVISIONED."
  }
}

variable "iam_admins" {
  description = "Usernames (keys of var.users) placed in the manually managed Role-IAM-Admins group."
  type        = list(string)
  default     = ["cara.diaz"]
}
