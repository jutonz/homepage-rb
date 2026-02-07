# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Development Commands

### Setup
- `bundle install` - Install Ruby gems
- `bin/rails db:prepare` - Set up database
- `bin/rails db:migrate` - Run database migrations

### Testing & Quality
- `bin/rspec` - Run RSpec test suite
- `bin/standardrb` - Ruby linting and code style (Standard gem)
* If these don't work, try prefixing with `mise exec --`, e.g. `mise exec -- bin/rspec`

### Assets & Frontend
- TailwindCSS is used for styling via `tailwindcss-rails` gem
- Stimulus controllers are in `app/javascript/controllers/`
- Importmap is used for JavaScript module management

## Architecture Overview

This is a Ruby on Rails 8.1 application with the following key architectural components:

### Core Functionality
- **Gallery Management**: Photo gallery system with image uploads, tagging, and organization
- **Todo System**: Personal task management with rooms and task tracking

### Key Models & Features
- **Galleries**: Core entity for organizing images with tags and social media links
- **Images**: Photo storage with perceptual hashing for similarity detection using `neighbor` gem
- **Tags**: Flexible tagging system with auto-tagging capabilities

### Technology Stack
- **Database**: PostgreSQL with vector extensions for image similarity
- **Background Jobs**: SolidQueue for job processing
- **Authentication**: Warden for session management
- **File Storage**: Active Storage (using minio s3 api)
- **Monitoring**: OpenTelemetry, Prometheus, and Sentry integration

### Directory Structure
- `app/components/` - ViewComponent components for reusable UI
- `app/queries/` - Query objects for complex database operations
- `app/jobs/` - Background job classes
- `spec/` - RSpec test files (preferred over `test/`)

### Authentication & Security
- Session-based authentication with OAuth callback support
- API token system for programmatic access
- Security scanning with Brakeman
- Credential encryption for different environments

## Rules

### Style rules
* YOU MUST limit line length to 80 characters.
* Do not use callbacks in controllers or models
* Omit the value in hashes when possible, e.g. rather than `{user: user}`, say just `{user:}`
* YOU MUST use parenthesis for all method calls
* Use double quoted strings, e.g. use `"this"`, not `'this'`
* Prefer global classes in app/assets/tailwind/application.css if one fits the use case.

### Testing rules
* Do not use `let`, `let!`, `before`, or `context`
* Use request specs instead of controller specs.
* Organize tests into distinct act/arrange/assert blocks
* Always add tests for new code
* Always run tests after creating or modifying them
* Use shoudla matches to test validations, e.g. `it { is_expected.to validate_presence_of(:email) }`
* Always prefer using factories to building an object manually (e.g. `MyRecord.new)
* Always prefer using `build` or `build_stubbed` over `create` in tests when possible
* When defining a factory, use a `sequence` for any field with a unique validation

## git commits
* Briefly explain the purpose of the change in 1-2 sentences.
