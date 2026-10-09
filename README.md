# Homepage

My homepage!

# Getting started

```bash
bin/setup
```

# Mutation testing

`bin/mutate` checks that your specs catch a broken version of your change. It
mutates the lines under `app/` that your branch changed since its merge-base
with `main`, including uncommitted and untracked files. It then runs the specs
that belong to the change:

* the spec files the branch changed, except system specs;
* the mirrored spec of each changed file in `app/`, for example
  `spec/models/user_spec.rb` for `app/models/user.rb`;
* the request spec of each changed controller.

```bash
bin/mutate                              # default spec selection
bin/mutate spec/models/user_spec.rb     # these specs only
bin/mutate -- --only 'User#name'        # pass flags to mutineer
```

The command fails when a mutation survives or when no spec reaches a changed
line, and it lists each one. `.mutineer.yml` holds the operator set. When a
mutation cannot change behavior, suppress it on its line with a reason:

```ruby
users_count > 10 # mutineer:disable-line comparison -- the reason
```
