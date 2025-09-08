---
id: task-0057
title: Update reddit social media link prefix
status: To Do
assignee: []
created_date: '2025-09-08 11:27'
labels: []
dependencies: []
---

## Description

Currently the prefix for reddit social media links is "RD:", however I'd like to make this `u/` instead to more closely match how reddit works. 

* Create a datat migration to update existing RD: prefixed tags to u/ 
* Update app/models/galleries/social_links_creator.rb and its test to look for a u/ prefix rather than RD:
