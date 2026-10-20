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

ActiveRecord::Schema[8.1].define(version: 2026_10_20_150802) do
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

  create_table "advance_payments", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "employee_id", null: false
    t.date "date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "payment_mode", default: "cash"
    t.string "reason"
    t.boolean "is_recovered", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_advance_payments_on_business_id"
    t.index ["employee_id"], name: "index_advance_payments_on_employee_id"
  end

  create_table "attendances", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "employee_id", null: false
    t.integer "work_project_id"
    t.date "date", null: false
    t.string "status", default: "present"
    t.decimal "overtime_hours", precision: 5, scale: 2, default: "0.0"
    t.decimal "wage_amount", precision: 10, scale: 2, default: "0.0"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_attendances_on_business_id"
    t.index ["employee_id"], name: "index_attendances_on_employee_id"
    t.index ["work_project_id"], name: "index_attendances_on_work_project_id"
  end

  create_table "businesses", force: :cascade do |t|
    t.string "name", null: false
    t.string "phone"
    t.string "email"
    t.string "currency_code", default: "INR"
    t.string "currency_symbol", default: "₹"
    t.text "address"
    t.string "tax_id"
    t.string "invoice_prefix", default: "INV"
    t.string "quotation_prefix", default: "EST"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "google_drive_connected", default: false
    t.string "google_drive_folder_id"
    t.text "google_drive_access_token"
    t.text "google_drive_refresh_token"
    t.datetime "google_drive_token_expires_at"
    t.string "google_drive_email"
    t.boolean "show_cash_flow_pulse", default: false, null: false
  end

  create_table "clients", force: :cascade do |t|
    t.integer "business_id", null: false
    t.string "name"
    t.string "company_name"
    t.string "phone"
    t.string "email"
    t.text "address"
    t.string "tax_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_clients_on_business_id"
  end

  create_table "employees", force: :cascade do |t|
    t.integer "business_id", null: false
    t.string "name", null: false
    t.string "phone"
    t.string "role_title"
    t.string "wage_type", default: "daily"
    t.decimal "base_rate", precision: 10, scale: 2, default: "0.0"
    t.decimal "overtime_hourly_rate", precision: 10, scale: 2, default: "0.0"
    t.string "status", default: "active"
    t.date "joined_date"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_employees_on_business_id"
  end

  create_table "expense_categories", force: :cascade do |t|
    t.integer "business_id", null: false
    t.string "name"
    t.string "color"
    t.string "icon"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_expense_categories_on_business_id"
  end

  create_table "expenses", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "expense_category_id", null: false
    t.integer "work_project_id"
    t.date "date", null: false
    t.decimal "amount", precision: 10, scale: 2, null: false
    t.string "paid_to"
    t.string "payment_mode", default: "cash"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_drive_file_id"
    t.string "google_drive_file_url"
    t.index ["business_id"], name: "index_expenses_on_business_id"
    t.index ["expense_category_id"], name: "index_expenses_on_expense_category_id"
    t.index ["work_project_id"], name: "index_expenses_on_work_project_id"
  end

  create_table "invoice_items", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.string "description", null: false
    t.decimal "quantity", precision: 10, scale: 2, default: "1.0"
    t.decimal "unit_price", precision: 10, scale: 2, default: "0.0"
    t.decimal "total_price", precision: 12, scale: 2, default: "0.0"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["invoice_id"], name: "index_invoice_items_on_invoice_id"
  end

  create_table "invoices", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "client_id"
    t.integer "work_project_id"
    t.string "doc_type", default: "invoice"
    t.string "invoice_number", null: false
    t.date "issue_date", null: false
    t.date "due_date"
    t.string "status", default: "draft"
    t.decimal "subtotal", precision: 12, scale: 2, default: "0.0"
    t.decimal "tax_rate", precision: 5, scale: 2, default: "0.0"
    t.decimal "tax_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "discount_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "total_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "paid_amount", precision: 12, scale: 2, default: "0.0"
    t.decimal "balance_amount", precision: 12, scale: 2, default: "0.0"
    t.text "terms"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "google_drive_file_id"
    t.string "google_drive_file_url"
    t.index ["business_id"], name: "index_invoices_on_business_id"
    t.index ["client_id"], name: "index_invoices_on_client_id"
    t.index ["work_project_id"], name: "index_invoices_on_work_project_id"
  end

  create_table "payment_receipts", force: :cascade do |t|
    t.integer "invoice_id", null: false
    t.integer "business_id", null: false
    t.date "date", null: false
    t.decimal "amount", precision: 12, scale: 2, default: "0.0"
    t.string "payment_mode", default: "cash"
    t.string "transaction_ref"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_payment_receipts_on_business_id"
    t.index ["invoice_id"], name: "index_payment_receipts_on_invoice_id"
  end

  create_table "sessions", force: :cascade do |t|
    t.integer "user_id", null: false
    t.string "ip_address"
    t.string "user_agent"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email_address", null: false
    t.string "password_digest", null: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "business_id"
    t.string "full_name"
    t.string "role", default: "owner"
    t.integer "employee_id"
    t.index ["business_id"], name: "index_users_on_business_id"
    t.index ["email_address"], name: "index_users_on_email_address", unique: true
    t.index ["employee_id"], name: "index_users_on_employee_id"
  end

  create_table "wage_payouts", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "employee_id", null: false
    t.date "period_start"
    t.date "period_end"
    t.decimal "gross_wage", precision: 10, scale: 2, default: "0.0"
    t.decimal "advances_deducted", precision: 10, scale: 2, default: "0.0"
    t.decimal "net_paid", precision: 10, scale: 2, default: "0.0"
    t.date "payment_date"
    t.string "payment_mode", default: "cash"
    t.string "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_wage_payouts_on_business_id"
    t.index ["employee_id"], name: "index_wage_payouts_on_employee_id"
  end

  create_table "work_projects", force: :cascade do |t|
    t.integer "business_id", null: false
    t.integer "client_id"
    t.string "title", null: false
    t.text "description"
    t.string "status", default: "in_progress"
    t.decimal "quoted_price", precision: 12, scale: 2, default: "0.0"
    t.date "start_date"
    t.date "end_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["business_id"], name: "index_work_projects_on_business_id"
    t.index ["client_id"], name: "index_work_projects_on_client_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "active_storage_variant_records", "active_storage_blobs", column: "blob_id"
  add_foreign_key "advance_payments", "businesses"
  add_foreign_key "advance_payments", "employees"
  add_foreign_key "attendances", "businesses"
  add_foreign_key "attendances", "employees"
  add_foreign_key "attendances", "work_projects"
  add_foreign_key "clients", "businesses"
  add_foreign_key "employees", "businesses"
  add_foreign_key "expense_categories", "businesses"
  add_foreign_key "expenses", "businesses"
  add_foreign_key "expenses", "expense_categories"
  add_foreign_key "expenses", "work_projects"
  add_foreign_key "invoice_items", "invoices"
  add_foreign_key "invoices", "businesses"
  add_foreign_key "invoices", "clients"
  add_foreign_key "invoices", "work_projects"
  add_foreign_key "payment_receipts", "businesses"
  add_foreign_key "payment_receipts", "invoices"
  add_foreign_key "sessions", "users"
  add_foreign_key "users", "businesses"
  add_foreign_key "users", "employees"
  add_foreign_key "wage_payouts", "businesses"
  add_foreign_key "wage_payouts", "employees"
  add_foreign_key "work_projects", "businesses"
  add_foreign_key "work_projects", "clients"
end
