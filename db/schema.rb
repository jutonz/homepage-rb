# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.0].define(version: 2025_10_13_180852) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "vector"

  create_table "action_text_rich_texts", force: :cascade do |t|
    t.string "name", null: false
    t.text "body"
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["record_type", "record_id", "name"], name: "index_action_text_rich_texts_uniqueness", unique: true
  end

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.string "service_name", null: false
    t.bigint "byte_size", null: false
    t.string "checksum"
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "active_storage_variant_records", force: :cascade do |t|
    t.bigint "blob_id", null: false
    t.string "variation_digest", null: false
    t.index ["blob_id", "variation_digest"], name: "index_active_storage_variant_records_uniqueness", unique: true
  end

  create_table "api_tokens", force: :cascade do |t|
    t.string "name", null: false
    t.string "token", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["token"], name: "index_api_tokens_on_token", unique: true
    t.index ["user_id", "name"], name: "index_api_tokens_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_api_tokens_on_user_id"
  end

  create_table "galleries", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.datetime "hidden_at"
    t.integer "images_count", default: 0, null: false
    t.integer "tags_count", default: 0, null: false
    t.index ["name"], name: "index_galleries_on_name", unique: true
    t.index ["user_id"], name: "index_galleries_on_user_id"
  end

  create_table "galleries_auto_add_tags", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.bigint "auto_add_tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["auto_add_tag_id"], name: "index_galleries_auto_add_tags_on_auto_add_tag_id"
    t.index ["tag_id", "auto_add_tag_id"], name: "index_galleries_auto_add_tags_on_tag_id_and_auto_add_tag_id", unique: true
    t.index ["tag_id"], name: "index_galleries_auto_add_tags_on_tag_id"
  end

  create_table "galleries_image_tags", force: :cascade do |t|
    t.bigint "image_id", null: false
    t.bigint "tag_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["image_id", "created_at"], name: "index_galleries_image_tags_on_image_id_and_created_at"
    t.index ["image_id"], name: "index_galleries_image_tags_on_image_id"
    t.index ["tag_id", "image_id"], name: "index_galleries_image_tags_on_tag_id_and_image_id", unique: true
    t.index ["tag_id"], name: "index_galleries_image_tags_on_tag_id"
  end

  create_table "galleries_images", force: :cascade do |t|
    t.bigint "gallery_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.vector "perceptual_hash", limit: 64
    t.index ["gallery_id"], name: "index_galleries_images_on_gallery_id"
  end

  create_table "galleries_social_media_links", force: :cascade do |t|
    t.bigint "tag_id", null: false
    t.string "platform", null: false
    t.string "username", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["platform", "username"], name: "index_galleries_social_media_links_on_platform_and_username", unique: true
    t.index ["tag_id"], name: "index_galleries_social_media_links_on_tag_id"
  end

  create_table "galleries_tags", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "gallery_id", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "image_tags_count", default: 0, null: false
    t.index ["gallery_id", "name"], name: "index_galleries_tags_on_gallery_id_and_name", unique: true
    t.index ["gallery_id"], name: "index_galleries_tags_on_gallery_id"
    t.index ["user_id"], name: "index_galleries_tags_on_user_id"
  end

  create_table "recipe_group_user_groups", force: :cascade do |t|
    t.bigint "recipe_group_id", null: false
    t.bigint "user_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["recipe_group_id", "user_group_id"], name: "idx_on_recipe_group_id_user_group_id_80860d9213", unique: true
    t.index ["recipe_group_id"], name: "index_recipe_group_user_groups_on_recipe_group_id"
    t.index ["user_group_id"], name: "index_recipe_group_user_groups_on_user_group_id"
  end

  create_table "recipe_groups", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "recipes_count", default: 0, null: false
    t.index ["owner_id"], name: "index_recipe_groups_on_owner_id"
  end

  create_table "recipes_ingredients", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id", "name"], name: "index_recipes_ingredients_on_user_id_and_name", unique: true
    t.index ["user_id"], name: "index_recipes_ingredients_on_user_id"
  end

  create_table "recipes_recipe_ingredients", force: :cascade do |t|
    t.bigint "recipe_id", null: false
    t.bigint "ingredient_id", null: false
    t.decimal "quantity", precision: 8, scale: 2
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "unit_id", null: false
    t.integer "numerator"
    t.integer "denominator"
    t.index ["ingredient_id"], name: "index_recipes_recipe_ingredients_on_ingredient_id"
    t.index ["recipe_id", "ingredient_id"], name: "idx_on_recipe_id_ingredient_id_b1a1ea5019", unique: true
    t.index ["recipe_id"], name: "index_recipes_recipe_ingredients_on_recipe_id"
    t.index ["unit_id"], name: "index_recipes_recipe_ingredients_on_unit_id"
  end

  create_table "recipes_recipes", force: :cascade do |t|
    t.string "name", null: false
    t.text "description"
    t.bigint "user_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "recipe_group_id", null: false
    t.index ["recipe_group_id"], name: "index_recipes_recipes_on_recipe_group_id"
    t.index ["user_id"], name: "index_recipes_recipes_on_user_id"
  end

  create_table "recipes_units", force: :cascade do |t|
    t.string "name", null: false
    t.string "abbreviation", null: false
    t.string "unit_type", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["abbreviation"], name: "index_recipes_units_on_abbreviation", unique: true
    t.index ["name"], name: "index_recipes_units_on_name", unique: true
    t.index ["unit_type"], name: "index_recipes_units_on_unit_type"
  end

  create_table "solid_queue_blocked_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.string "concurrency_key", null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.index ["concurrency_key", "priority", "job_id"], name: "index_solid_queue_blocked_executions_for_release"
    t.index ["expires_at", "concurrency_key"], name: "index_solid_queue_blocked_executions_for_maintenance"
    t.index ["job_id"], name: "index_solid_queue_blocked_executions_on_job_id", unique: true
  end

  create_table "solid_queue_claimed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.bigint "process_id"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_claimed_executions_on_job_id", unique: true
    t.index ["process_id", "job_id"], name: "index_solid_queue_claimed_executions_on_process_id_and_job_id"
  end

  create_table "solid_queue_failed_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.text "error"
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_failed_executions_on_job_id", unique: true
  end

  create_table "solid_queue_jobs", force: :cascade do |t|
    t.string "queue_name", null: false
    t.string "class_name", null: false
    t.text "arguments"
    t.integer "priority", default: 0, null: false
    t.string "active_job_id"
    t.datetime "scheduled_at"
    t.datetime "finished_at"
    t.string "concurrency_key"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["active_job_id"], name: "index_solid_queue_jobs_on_active_job_id"
    t.index ["class_name"], name: "index_solid_queue_jobs_on_class_name"
    t.index ["finished_at"], name: "index_solid_queue_jobs_on_finished_at"
    t.index ["queue_name", "finished_at"], name: "index_solid_queue_jobs_for_filtering"
    t.index ["scheduled_at", "finished_at"], name: "index_solid_queue_jobs_for_alerting"
  end

  create_table "solid_queue_pauses", force: :cascade do |t|
    t.string "queue_name", null: false
    t.datetime "created_at", null: false
    t.index ["queue_name"], name: "index_solid_queue_pauses_on_queue_name", unique: true
  end

  create_table "solid_queue_processes", force: :cascade do |t|
    t.string "kind", null: false
    t.datetime "last_heartbeat_at", null: false
    t.bigint "supervisor_id"
    t.integer "pid", null: false
    t.string "hostname"
    t.text "metadata"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.index ["last_heartbeat_at"], name: "index_solid_queue_processes_on_last_heartbeat_at"
    t.index ["name", "supervisor_id"], name: "index_solid_queue_processes_on_name_and_supervisor_id", unique: true
    t.index ["supervisor_id"], name: "index_solid_queue_processes_on_supervisor_id"
  end

  create_table "solid_queue_ready_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_ready_executions_on_job_id", unique: true
    t.index ["priority", "job_id"], name: "index_solid_queue_poll_all"
    t.index ["queue_name", "priority", "job_id"], name: "index_solid_queue_poll_by_queue"
  end

  create_table "solid_queue_recurring_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "task_key", null: false
    t.datetime "run_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_recurring_executions_on_job_id", unique: true
    t.index ["task_key", "run_at"], name: "index_solid_queue_recurring_executions_on_task_key_and_run_at", unique: true
  end

  create_table "solid_queue_recurring_tasks", force: :cascade do |t|
    t.string "key", null: false
    t.string "schedule", null: false
    t.string "command", limit: 2048
    t.string "class_name"
    t.text "arguments"
    t.string "queue_name"
    t.integer "priority", default: 0
    t.boolean "static", default: true, null: false
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["key"], name: "index_solid_queue_recurring_tasks_on_key", unique: true
    t.index ["static"], name: "index_solid_queue_recurring_tasks_on_static"
  end

  create_table "solid_queue_scheduled_executions", force: :cascade do |t|
    t.bigint "job_id", null: false
    t.string "queue_name", null: false
    t.integer "priority", default: 0, null: false
    t.datetime "scheduled_at", null: false
    t.datetime "created_at", null: false
    t.index ["job_id"], name: "index_solid_queue_scheduled_executions_on_job_id", unique: true
    t.index ["scheduled_at", "priority", "job_id"], name: "index_solid_queue_dispatch_all"
  end

  create_table "solid_queue_semaphores", force: :cascade do |t|
    t.string "key", null: false
    t.integer "value", default: 1, null: false
    t.datetime "expires_at", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["expires_at"], name: "index_solid_queue_semaphores_on_expires_at"
    t.index ["key", "value"], name: "index_solid_queue_semaphores_on_key_and_value"
    t.index ["key"], name: "index_solid_queue_semaphores_on_key", unique: true
  end

  create_table "task_occurrences", force: :cascade do |t|
    t.bigint "todo_task_id", null: false
    t.string "todoist_task_id", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "status"
    t.index ["todo_task_id"], name: "index_task_occurrences_on_todo_task_id"
    t.index ["todoist_task_id"], name: "index_task_occurrences_on_todoist_task_id", unique: true
  end

  create_table "task_records", id: false, force: :cascade do |t|
    t.string "version", null: false
  end

  create_table "todo_room_tasks", force: :cascade do |t|
    t.bigint "task_id", null: false
    t.bigint "room_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["room_id"], name: "index_todo_room_tasks_on_room_id"
    t.index ["task_id"], name: "index_todo_room_tasks_on_task_id"
  end

  create_table "todo_rooms", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_todo_rooms_on_user_id"
  end

  create_table "todo_task_occurrences", force: :cascade do |t|
    t.bigint "todo_task_id", null: false
    t.string "todoist_task_id", null: false
    t.datetime "scheduled_at", null: false
    t.datetime "completed_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["todo_task_id"], name: "index_todo_task_occurrences_on_todo_task_id"
    t.index ["todoist_task_id"], name: "index_todo_task_occurrences_on_todoist_task_id", unique: true
  end

  create_table "todo_tasks", force: :cascade do |t|
    t.string "name", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id", null: false
    t.index ["user_id"], name: "index_todo_tasks_on_user_id"
  end

  create_table "user_group_invitations", force: :cascade do |t|
    t.string "email", null: false
    t.bigint "user_group_id", null: false
    t.string "token", null: false
    t.datetime "expires_at", null: false
    t.datetime "accepted_at"
    t.bigint "invited_by_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["accepted_at"], name: "index_user_group_invitations_on_accepted_at"
    t.index ["email", "user_group_id"], name: "index_user_group_invitations_on_email_and_user_group_id", unique: true
    t.index ["email"], name: "index_user_group_invitations_on_email"
    t.index ["expires_at"], name: "index_user_group_invitations_on_expires_at"
    t.index ["invited_by_id"], name: "index_user_group_invitations_on_invited_by_id"
    t.index ["token"], name: "index_user_group_invitations_on_token", unique: true
    t.index ["user_group_id"], name: "index_user_group_invitations_on_user_group_id"
  end

  create_table "user_group_memberships", force: :cascade do |t|
    t.bigint "user_id", null: false
    t.bigint "user_group_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_group_id"], name: "index_user_group_memberships_on_user_group_id"
    t.index ["user_id", "user_group_id"], name: "index_user_group_memberships_on_user_id_and_user_group_id", unique: true
    t.index ["user_id"], name: "index_user_group_memberships_on_user_id"
  end

  create_table "user_groups", force: :cascade do |t|
    t.string "name", null: false
    t.bigint "owner_id", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "users_count", default: 0, null: false
    t.index ["owner_id"], name: "index_user_groups_on_owner_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", null: false
    t.string "foreign_id", null: false
    t.string "access_token", null: false
    t.string "refresh_token", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["foreign_id"], name: "index_users_on_foreign_id", unique: true
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "galleries", "users"
  add_foreign_key "galleries_auto_add_tags", "galleries_tags", column: "auto_add_tag_id"
  add_foreign_key "galleries_auto_add_tags", "galleries_tags", column: "tag_id"
  add_foreign_key "galleries_image_tags", "galleries_images", column: "image_id"
  add_foreign_key "galleries_image_tags", "galleries_tags", column: "tag_id"
  add_foreign_key "galleries_images", "galleries"
  add_foreign_key "galleries_social_media_links", "galleries_tags", column: "tag_id"
  add_foreign_key "galleries_tags", "galleries"
  add_foreign_key "galleries_tags", "users"
  add_foreign_key "recipe_group_user_groups", "recipe_groups"
  add_foreign_key "recipe_group_user_groups", "user_groups"
  add_foreign_key "recipe_groups", "users", column: "owner_id"
  add_foreign_key "recipes_ingredients", "users"
  add_foreign_key "recipes_recipe_ingredients", "recipes_ingredients", column: "ingredient_id"
  add_foreign_key "recipes_recipe_ingredients", "recipes_recipes", column: "recipe_id"
  add_foreign_key "recipes_recipe_ingredients", "recipes_units", column: "unit_id"
  add_foreign_key "recipes_recipes", "recipe_groups"
  add_foreign_key "recipes_recipes", "users"
  add_foreign_key "solid_queue_blocked_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_claimed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_failed_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_ready_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_recurring_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "solid_queue_scheduled_executions", "solid_queue_jobs", column: "job_id", on_delete: :cascade
  add_foreign_key "task_occurrences", "todo_tasks"
  add_foreign_key "todo_room_tasks", "todo_rooms", column: "room_id"
  add_foreign_key "todo_room_tasks", "todo_tasks", column: "task_id"
  add_foreign_key "todo_task_occurrences", "todo_tasks"
  add_foreign_key "todo_tasks", "users"
  add_foreign_key "user_group_invitations", "user_groups"
  add_foreign_key "user_group_invitations", "users", column: "invited_by_id"
  add_foreign_key "user_group_memberships", "user_groups"
  add_foreign_key "user_group_memberships", "users"
  add_foreign_key "user_groups", "users", column: "owner_id"
end
