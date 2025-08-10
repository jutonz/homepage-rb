---
id: task-0023
title: Add Gallery Image policy
status: Done
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels:
  - authorization
  - gallery
dependencies:
  - task-0022
---

## Description

Create Galleries::ImagePolicy for image management within galleries and integrate it with both the Galleries::ImagesController and related API controllers.

## Acceptance Criteria

- [ ] Galleries::ImagePolicy is created with appropriate CRUD methods
- [ ] Policy handles image permissions based on gallery ownership and visibility
- [ ] Galleries::ImagesController integrates policy authorization
- [ ] API controllers for gallery images use policy authorization
- [ ] Policy scope filters images based on gallery permissions
- [ ] Comprehensive tests cover image authorization scenarios
- [ ] Integration tests verify both web and API controller authorization
