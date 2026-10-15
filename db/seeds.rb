puts "== Seeding KarigarBook Small Business Management OS =="

# 1. Clean previous demo data
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
Session.destroy_all
User.destroy_all
Business.destroy_all

# 2. Create Business
business = Business.create!(
  name: "Apex Engineering & Fabrication Works",
  phone: "+91 98450 12345",
  email: "contact@apexengg.com",
  currency_code: "INR",
  currency_symbol: "₹",
  address: "Plot 14-B, Peenya Industrial Area, Phase 2, Bangalore, KA 560058",
  tax_id: "29AABCU9603R1ZM",
  invoice_prefix: "APX-INV",
  quotation_prefix: "APX-EST",
  google_drive_connected: true,
  google_drive_email: "ramesh.apex@gmail.com",
  google_drive_folder_id: "folder_apex_engineering_docs"
)

# 3. Create Super Admin (Platform Owner)
super_admin = User.find_or_initialize_by(email_address: "superadmin@karigarbook.com")
super_admin.assign_attributes(
  full_name: "Platform Super Admin",
  password: "password123",
  password_confirmation: "password123",
  role: "super_admin",
  business: nil
)
super_admin.save!

# 4. Create Business Owner (Admin)
owner = business.users.find_or_initialize_by(email_address: "ramesh@apexengg.com")
owner.assign_attributes(
  full_name: "Ramesh Kumar (Owner)",
  password: "password123",
  password_confirmation: "password123",
  role: "admin"
)
owner.save!

puts "✓ Created Super Admin: superadmin@karigarbook.com / password123"
puts "✓ Created Business: #{business.name} (Owner: #{owner.email_address} / password123)"

# 4. Create Clients
client1 = business.clients.create!(
  name: "Vikram Malhotra",
  company_name: "Malhotra Logistics Park",
  phone: "+91 98765 43210",
  email: "vikram@malhotralogistics.com",
  address: "NH48 Warehouse Zone, Nelamangala",
  tax_id: "29AACCM4455B1Z0"
)

client2 = business.clients.create!(
  name: "Pooja Reddy",
  company_name: "Reddy Villa Project",
  phone: "+91 99887 76655",
  email: "pooja.reddy@gmail.com",
  address: "Site 88, HSR Layout Sector 2, Bangalore"
)

client3 = business.clients.create!(
  name: "Sunil Hegde",
  company_name: "Hegde Food Processing Unit",
  phone: "+91 91234 56789",
  email: "sunil@hegdefoods.in",
  address: "KIADB Industrial Area, Bidadi"
)

# 5. Create Work Projects
project1 = business.work_projects.create!(
  client: client1,
  title: "Warehouse Industrial Shed & Truss Fabrication",
  description: "Complete fabrication of heavy duty MS trusses, purlins, and sheet roofing for 4000 sq ft bay",
  status: "in_progress",
  quoted_price: 380000.0,
  start_date: Date.current - 12.days,
  end_date: Date.current + 18.days
)

project2 = business.work_projects.create!(
  client: client2,
  title: "Stainless Steel Staircase Railing & Balcony Grills",
  description: "Grade 304 SS laser cut designer railing and main gate fabrication",
  status: "completed",
  quoted_price: 125000.0,
  start_date: Date.current - 25.days,
  end_date: Date.current - 2.days
)

project3 = business.work_projects.create!(
  client: client3,
  title: "Heavy Conveyor Belt Frame & Motor Mounts",
  description: "Custom structural steel framework for food packing line",
  status: "quoted",
  quoted_price: 95000.0,
  start_date: Date.current - 3.days
)

# 6. Create Laborers / Employees
emp1 = business.employees.create!(
  name: "Muthu Vel",
  phone: "+91 97400 11221",
  role_title: "Senior Arc Welder",
  wage_type: "daily",
  base_rate: 850.0,
  overtime_hourly_rate: 150.0,
  status: "active",
  joined_date: Date.current - 6.months
)

# Create Employee User Account (Normal User)
emp_user = business.users.find_or_initialize_by(email_address: "muthu@apexengg.com")
emp_user.assign_attributes(
  full_name: "Muthu Vel",
  password: "password123",
  password_confirmation: "password123",
  role: "employee",
  employee: emp1
)
emp_user.save!
puts "✓ Created Employee User: #{emp_user.email_address} / password123 (Linked to Muthu Vel)"

emp2 = business.employees.create!(
  name: "Basavaraj Patil",
  phone: "+91 97400 33442",
  role_title: "Fabricator & Fitter",
  wage_type: "daily",
  base_rate: 800.0,
  overtime_hourly_rate: 140.0,
  status: "active",
  joined_date: Date.current - 4.months
)

emp3 = business.employees.create!(
  name: "Ganesh Naik",
  phone: "+91 97400 55663",
  role_title: "Gas Cutter & Helper",
  wage_type: "daily",
  base_rate: 650.0,
  overtime_hourly_rate: 100.0,
  status: "active",
  joined_date: Date.current - 3.months
)

emp4 = business.employees.create!(
  name: "Manjunath K",
  phone: "+91 97400 77884",
  role_title: "Workshop Helper / Loader",
  wage_type: "daily",
  base_rate: 550.0,
  overtime_hourly_rate: 90.0,
  status: "active",
  joined_date: Date.current - 2.months
)

emp5 = business.employees.create!(
  name: "Shankar Rao",
  phone: "+91 97400 99005",
  role_title: "Lathe Operator & Machinist",
  wage_type: "weekly",
  base_rate: 5500.0,
  overtime_hourly_rate: 150.0,
  status: "active",
  joined_date: Date.current - 1.year
)

emp6 = business.employees.create!(
  name: "Imran Khan",
  phone: "+91 97400 12300",
  role_title: "Site Supervisor & Driver",
  wage_type: "monthly",
  base_rate: 24000.0,
  overtime_hourly_rate: 0.0,
  status: "active",
  joined_date: Date.current - 8.months
)

# 7. Worker Advances (Khata)
business.advance_payments.create!(
  employee: emp1,
  date: Date.current - 5.days,
  amount: 1500.0,
  payment_mode: "cash",
  reason: "Medical expense for daughter",
  is_recovered: false
)

business.advance_payments.create!(
  employee: emp3,
  date: Date.current - 8.days,
  amount: 800.0,
  payment_mode: "upi",
  reason: "Festival travel advance",
  is_recovered: false
)

# 8. Attendances for the last 10 days
(0..9).reverse_each do |days_ago|
  date = Date.current - days_ago.days
  next if date.sunday? # Sunday holiday

  # Muthu Vel
  business.attendances.create!(
    employee: emp1,
    work_project: project1,
    date: date,
    status: "present",
    overtime_hours: (days_ago % 3 == 0) ? 2.0 : 0.0,
    wage_amount: emp1.calculate_day_wage("present", (days_ago % 3 == 0) ? 2.0 : 0.0),
    notes: "Site welding work"
  )

  # Basavaraj Patil
  business.attendances.create!(
    employee: emp2,
    work_project: project1,
    date: date,
    status: (days_ago == 4) ? "half_day" : "present",
    overtime_hours: 1.0,
    wage_amount: emp2.calculate_day_wage((days_ago == 4) ? "half_day" : "present", 1.0)
  )

  # Ganesh Naik
  business.attendances.create!(
    employee: emp3,
    work_project: (days_ago < 5) ? project1 : project2,
    date: date,
    status: (days_ago == 2) ? "absent" : "present",
    overtime_hours: 0.0,
    wage_amount: emp3.calculate_day_wage((days_ago == 2) ? "absent" : "present", 0.0)
  )

  # Manjunath
  business.attendances.create!(
    employee: emp4,
    work_project: nil, # Shop floor / general
    date: date,
    status: "present",
    overtime_hours: 0.0,
    wage_amount: emp4.calculate_day_wage("present", 0.0),
    notes: "Workshop raw material cutting"
  )
end

# 9. Expenses (Tea, Meals, Hardware, Fuel)
tea_cat = business.expense_categories.find_by(name: "Tea & Refreshments")
food_cat = business.expense_categories.find_by(name: "Food & Meals")
mat_cat = business.expense_categories.find_by(name: "Hardware & Materials")
fuel_cat = business.expense_categories.find_by(name: "Fuel & Transport")

# Tea logs
(0..7).each do |days_ago|
  date = Date.current - days_ago.days
  business.expenses.create!(
    expense_category: tea_cat,
    work_project: project1,
    date: date,
    amount: 140.0,
    paid_to: "Shree Krishna Tea Stall",
    payment_mode: "upi",
    notes: "Morning & evening tea + biscuits for 6 workers",
    google_drive_file_id: "drive_tea_#{SecureRandom.hex(4)}",
    google_drive_file_url: "https://drive.google.com/file/d/demo_tea_bill/view"
  )
end

# Lunch for crew on heavy welding day
business.expenses.create!(
  expense_category: food_cat,
  work_project: project1,
  date: Date.current - 3.days,
  amount: 720.0,
  paid_to: "Udupi Grand Hotel",
  payment_mode: "cash",
  notes: "Meals provided to overtime site crew (6 members)",
  google_drive_file_id: "drive_lunch_#{SecureRandom.hex(4)}",
  google_drive_file_url: "https://drive.google.com/file/d/demo_lunch_bill/view"
)

# Hardware: Welding electrodes, cutting wheels
business.expenses.create!(
  expense_category: mat_cat,
  work_project: project1,
  date: Date.current - 10.days,
  amount: 24500.0,
  paid_to: "Sri Balaji Steels & Hardware",
  payment_mode: "bank",
  notes: "12 boxes welding electrodes 7018 + 50 cutting wheels 14-inch",
  google_drive_file_id: "drive_materials_#{SecureRandom.hex(4)}",
  google_drive_file_url: "https://drive.google.com/file/d/demo_hardware_bill/view"
)

# Fuel for site pickup generator
business.expenses.create!(
  expense_category: fuel_cat,
  work_project: project1,
  date: Date.current - 6.days,
  amount: 3200.0,
  paid_to: "Indian Oil Petrol Bunk",
  payment_mode: "upi",
  notes: "35 liters diesel for site generator & pickup transport",
  google_drive_file_id: "drive_fuel_#{SecureRandom.hex(4)}",
  google_drive_file_url: "https://drive.google.com/file/d/demo_fuel_receipt/view"
)

# General overhead tea/coffee for office
business.expenses.create!(
  expense_category: tea_cat,
  work_project: nil,
  date: Date.current - 1.day,
  amount: 220.0,
  paid_to: "Nandini Milk Parlour",
  payment_mode: "cash",
  notes: "Milk and coffee powder for workshop office"
)

# 10. Invoices & Quotations
# Invoice 1 for Project 2 (Completed - fully paid)
inv1 = business.invoices.create!(
  client: client2,
  work_project: project2,
  doc_type: "invoice",
  invoice_number: "APX-INV-2026-001",
  issue_date: Date.current - 15.days,
  due_date: Date.current - 1.day,
  status: "paid",
  subtotal: 125000.0,
  tax_rate: 18.0,
  discount_amount: 5000.0,
  terms: "Payment received in full. Thank you for choosing Apex Engineering.",
  notes: "SS 304 laser railings and powder coated gate delivered."
)

inv1.invoice_items.create!(
  description: "Grade 304 Stainless Steel Staircase Railing (75 running feet @ ₹1,200)",
  quantity: 75,
  unit_price: 1200.0
)
inv1.invoice_items.create!(
  description: "Laser Cut Designer Balcony Safety Grills & Gate Fabrication",
  quantity: 1,
  unit_price: 35000.0
)
inv1.recalculate_totals!
inv1.save!

# Payment for Invoice 1
business.payment_receipts.create!(
  invoice: inv1,
  date: Date.current - 5.days,
  amount: inv1.total_amount,
  payment_mode: "bank",
  transaction_ref: "NEFT-HDFC-99120349",
  notes: "Final settlement received via NEFT"
)

# Invoice 2 for Project 1 (In Progress - 50% Advance invoiced)
inv2 = business.invoices.create!(
  client: client1,
  work_project: project1,
  doc_type: "invoice",
  invoice_number: "APX-INV-2026-002",
  issue_date: Date.current - 7.days,
  due_date: Date.current + 7.days,
  status: "partial",
  subtotal: 190000.0,
  tax_rate: 18.0,
  discount_amount: 0.0,
  terms: "50% advance on structural material delivery, balance 50% on completion."
)

inv2.invoice_items.create!(
  description: "Mobilization & Material Delivery for 4000 sq ft Industrial Warehouse Shed (50% Milestone)",
  quantity: 1,
  unit_price: 190000.0
)
inv2.recalculate_totals!
inv2.save!

# Partial payment on Invoice 2
business.payment_receipts.create!(
  invoice: inv2,
  date: Date.current - 4.days,
  amount: 100000.0,
  payment_mode: "bank",
  transaction_ref: "RTGS-ICICI-8812048",
  notes: "Part advance payment from Vikram Malhotra"
)

# Quotation 1 for Project 3
quote1 = business.invoices.create!(
  client: client3,
  work_project: project3,
  doc_type: "quotation",
  invoice_number: "APX-EST-2026-001",
  issue_date: Date.current - 2.days,
  due_date: Date.current + 12.days,
  status: "sent",
  subtotal: 95000.0,
  tax_rate: 18.0,
  discount_amount: 3000.0,
  terms: "Quotation valid for 15 days. Steel rates subject to market fluctuations."
)

quote1.invoice_items.create!(
  description: "Heavy Structural Channel Frame for 40ft Food Grade Conveyor",
  quantity: 1,
  unit_price: 65000.0
)
quote1.invoice_items.create!(
  description: "Precision Motor Mounting Brackets & Vibration Dampeners",
  quantity: 4,
  unit_price: 7500.0
)
quote1.recalculate_totals!
quote1.save!

puts "== Seed complete! Generated 6 employees, 3 projects, attendances, tea/food expenses, invoices & receipts =="
