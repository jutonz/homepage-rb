---
id: task-0033
title: Add authorization to Gallery utility controllers
status: Done
assignee: []
created_date: '2025-08-11 01:02'
updated_date: '2025-08-11 02:18'
labels:
  - authorization
  - galleries
dependencies: []
ordinal: 6000
---

## Description

Add proper Pundit authorization to TagSearchesController which currently only use authentication checks.

## Acceptance Criteria

- [ ] TagSearchesController includes authorize calls for all actions
- [ ] Controllers integrate with existing gallery authorization patterns
- [ ] Manual current_user scoping is replaced with policy-based authorization where appropriate

## Implementation Notes

Implementation completed successfully:

- Added proper Pundit authorization to TagSearchesController (the only utility controller missing authorization)
- Added after_action :verify_authorized and authorize @gallery, :show? for proper authorization verification
- Replaced manual current_user.galleries.find calls with policy_scope(Gallery).find for secure resource finding
- Replaced manual image scoping with policy_scope(Galleries::Image).where(gallery: @gallery).find
- Created comprehensive request specs for TagSearchesController authorization with authentication and ownership tests
- Verified AutoAddTagsController and BulkUploadsController already have complete authorization implementation
- All 63 Gallery request specs passing, confirming authorization works correctly across all Gallery utility controllers
- Code passes StandardRB style checks

All Gallery utility controllers now have proper Pundit authorization with comprehensive test coverage.
