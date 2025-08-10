---
id: task-16
title: Allow creating new ingredients while adding them
status: To Do
assignee: []
created_date: '2025-08-10'
updated_date: '2025-08-10'
labels: []
dependencies: []
---

## Description

Currently on a route like `/recipes/2/ingredients/new`, the only ingredients you can add are those which have already been created. Let's figure out a way to do `find_or_create_by` here to create the ingredient if it doesn't exist already. That will make it much less time consuming to add ingredients.
