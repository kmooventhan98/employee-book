puts "== Seeding KarigarBook Platform Super Admin =="

# 1. Clean previous demo data in foreign-key dependency order
Session.destroy_all
User.destroy_all
PaymentReceipt.destroy_all
InvoiceItem.destroy_all
Invoice.destroy_all
Expense.destroy_all
ExpenseCategory.destroy_all
WagePayout.destroy_all
AdvancePayment.destroy_all
Attendance.destroy_all
Employee.destroy_all
WorkProject.destroy_all
Client.destroy_all
Business.destroy_all

# 2. Create Super Admin (Platform Owner)
super_admin_password = ENV.fetch("SUPER_ADMIN_PASSWORD", "password123")

super_admin = User.find_or_initialize_by(email_address: "mooventhan@zohomail.in")
super_admin.assign_attributes(
  full_name: "Mooventhan",
  password: super_admin_password,
  password_confirmation: super_admin_password,
  role: "super_admin",
  business: nil
)
super_admin.save!

puts "✓ Super Admin created successfully:"
puts "  Email:    #{super_admin.email_address}"
puts "  Name:     #{super_admin.full_name}"
puts "  Role:     #{super_admin.role}"
puts "  Password: #{super_admin_password}"
puts "== Seed complete! Only Super Admin created. Ready to onboard real businesses. =="
