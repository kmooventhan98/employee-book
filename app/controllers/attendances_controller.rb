class AttendancesController < ApplicationController
  def index
    redirect_to bulk_attendances_path
  end

  def bulk
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @employees = current_business.employees.active.order(:name)
    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"]).order(:title)

    # Existing attendances for this date
    existing_attendances = current_business.attendances.where(date: @selected_date).index_by(&:employee_id)

    @attendance_records = @employees.map do |emp|
      existing = existing_attendances[emp.id]
      existing || current_business.attendances.build(
        employee: emp,
        date: @selected_date,
        status: "present",
        overtime_hours: 0.0,
        wage_amount: emp.calculate_day_wage("present", 0.0)
      )
    end

    # Daily Summary stats
    @total_laborers = @employees.count
    marked = existing_attendances.values
    @present_count = marked.count { |a| a.status == "present" }
    @half_count = marked.count { |a| a.status == "half_day" }
    @absent_count = marked.count { |a| a.status == "absent" }
    @total_day_wage = marked.sum(&:wage_amount)
  end

  def bulk_update
    date = Date.parse(params[:date])
    attendances_params = params[:attendances] || {}

    ActiveRecord::Base.transaction do
      attendances_params.each do |employee_id, att_attrs|
        emp = current_business.employees.find(employee_id)
        att = current_business.attendances.find_or_initialize_by(
          employee: emp,
          date: date
        )

        status = att_attrs[:status]
        ot_hours = att_attrs[:overtime_hours].to_f
        project_id = att_attrs[:work_project_id].presence

        att.status = status
        att.overtime_hours = ot_hours
        att.work_project_id = project_id
        att.notes = att_attrs[:notes]
        att.wage_amount = emp.calculate_day_wage(status, ot_hours)
        att.save!
      end
    end

    redirect_to bulk_attendances_path(date: date), notice: "Attendance saved for #{date.strftime('%d %B %Y')}! Total wages accrued: #{current_business.formatted_currency(current_business.attendances.where(date: date).sum(:wage_amount))}."
  rescue => e
    redirect_to bulk_attendances_path(date: date), alert: "Error saving attendance: #{e.message}"
  end
end
