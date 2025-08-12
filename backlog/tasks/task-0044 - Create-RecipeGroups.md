---
id: task-0044
title: Create RecipeGroups
status: In Progress
assignee: []
created_date: '2025-08-12 01:19'
updated_date: '2025-08-12 01:24'
labels: []
dependencies: []
---

## Description

A recipe group is a grouping of recipes. It has a name and a description.

* A RecipeGroup has many Recipes
* A RecipeGroup belongs to an Owner, which is a user
* A RecipeGroup can have many UserGroups
* A Recipe cannot exist on its own. It must belong to a RecipeGroup. Do not worry about backwords compatibility. Delete all existing recipes.
* Replace the existing recipe index page with a show page for a RecipeGroup.
* From the RecipeGroup show page, you can add new recipes.
* A RecipeGroup has an edit page where you can change its name or description, or add/remove it from UserGroups. You can only add it to a UserGroup if you are a member of that UserGroup.

The show page for a RecipeGroup looks very similar to the index page for recipes. You can add
