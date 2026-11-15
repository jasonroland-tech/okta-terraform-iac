# A bookmark app stands in for a real SaaS app so the lab costs nothing.
# Access comes from group membership, never from assigning the app to individual users.
resource "okta_app_bookmark" "github" {
  label = "Lakeview GitHub"
  url   = "https://github.com"
}

resource "okta_app_group_assignments" "github" {
  app_id = okta_app_bookmark.github.id

  group {
    id       = okta_group.department["Engineering"].id
    priority = 1
  }
}
