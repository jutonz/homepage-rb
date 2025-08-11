---
id: task-0034
title: Create missing Pundit policies for Gallery models
status: To Do
assignee: []
created_date: '2025-08-11 01:03'
labels:
  - authorization
  - policies
  - galleries
dependencies: []
---

## Description

Create Pundit policies for SocialMediaLink AutoAddTag and any other Gallery-related models that need authorization but lack policies.

## Acceptance Criteria

- [ ] SocialMediaLinkPolicy is created with appropriate permissions
- [ ] AutoAddTagPolicy is created with appropriate permissions
- [ ] Policies follow existing Gallery authorization patterns
- [ ] Policies integrate with nested resource authorization (gallery -> tag -> social_media_link)
- [ ] Policies include proper user ownership checks and permission methods
