---
id: task-0032
title: Add authorization to Gallery SocialMediaLinksController
status: Done
assignee: []
created_date: '2025-08-11 01:02'
updated_date: '2025-08-11 02:12'
labels:
  - authorization
  - galleries
dependencies: []
ordinal: 2000
---

## Description

Replace authentication-only checks with proper Pundit authorization in SocialMediaLinksController. This controller currently only checks authentication but needs full authorization.

## Acceptance Criteria

- [ ] SocialMediaLinksController calls authorize for each action
- [ ] All CRUD actions (new create edit update destroy) include proper authorization
- [ ] Controller removes manual current_user.galleries.find calls in favor of policy-based authorization
- [ ] Authorization works for nested resource structure (gallery -> tag -> social_media_link)
- [ ] Error handling provides appropriate feedback for unauthorized access
