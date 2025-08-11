---
id: task-28
title: Verify policy use globally
status: To Do
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-11 02:08'
labels: []
dependencies: []
ordinal: 3000
---

## Description

Once all controllers have it, move `after_action :verify_authorized` to `ApplicationController` and remove it from all other controllers.
