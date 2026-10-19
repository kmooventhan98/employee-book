class AttendancesController < ApplicationController
  def index
    redirect_to bulk_attendances_path
  end

  def bulk
    @selected_date = params[:date].present? ? Date.parse(params[:date]) : Date.current
    @current_mode = params[:mode].presence || "tiles"

    if employee?
      @linked_employee = current_user.employee || current_business.employees.find_by("LOWER(name) = ? OR phone = ?", current_user.full_name.downcase, current_user.email_address)
      @employees = @linked_employee ? [@linked_employee] : []
    else
      @employees = current_business.employees.active.order(:name)
    end

    @active_projects = current_business.work_projects.where(status: ["in_progress", "quoted"]).order(:title)

    # Existing attendances for this date
    existing_attendances = current_business.attendances.where(date: @selected_date).index_by(&:employee_id)

    @attendance_records = @employees.map do |emp|
      existing = existing_attendances[emp.id]
      # BY DEFAULT ALL SHOULD BE IN ABSENT per user instruction!
      existing || current_business.attendances.build(
        employee: emp,
        date: @selected_date,
        status: "absent",
        overtime_hours: 0.0,
        wage_amount: 0.0
      )
    end

    # Daily Summary stats
    @total_laborers = @employees.count
    marked = existing_attendances.values
    @present_count = marked.count { |a| a.status == "present" }
    @half_count = marked.count { |a| a.status == "half_day" }
    @absent_count = @total_laborers - (@present_count + @half_count + marked.count { |a| a.status == "paid_leave" })
    @leave_count = marked.count { |a| a.status == "paid_leave" }
    @total_day_wage = marked.sum(&:wage_amount)
  end

  def calendar
    @month_date = params[:month].present? ? Date.parse(params[:month]) : Date.current.beginning_of_month
    @prev_month = @month_date.prev_month
    @next_month = @month_date.next_month

    @start_calendar = @month_date.beginning_of_month.beginning_of_week(:monday)
    @end_calendar = @month_date.end_of_month.end_of_week(:sunday)

    if employee?
      @linked_employee = current_user.employee || current_business.employees.find_by("LOWER(name) = ? OR phone = ?", current_user.full_name.downcase, current_user.email_address)
      scope = @linked_employee ? @linked_employee.attendances : current_business.attendances.none
      @total_laborers = 1
    else
      scope = current_business.attendances
      @total_laborers = current_business.employees.active.count
    end

    month_atts = scope.where(date: @start_calendar..@end_calendar)
    @attendances_by_date = month_atts.group_by(&:date)

    # Monthly Summary Stats (for the calendar month)
    curr_month_atts = scope.where(date: @month_date.beginning_of_month..@month_date.end_of_month)
    @monthly_present_days = curr_month_atts.where(status: "present").count
    @monthly_half_days = curr_month_atts.where(status: "half_day").count
    @monthly_ot_hours = curr_month_atts.sum(:overtime_hours)
    @monthly_total_wages = curr_month_atts.sum(:wage_amount)
  end

  def bulk_update
    date = Date.parse(params[:date])
    attendances_params = params[:attendances] || {}

    if employee?
      linked_emp = current_user.employee || current_business.employees.find_by("LOWER(name) = ? OR phone = ?", current_user.full_name.downcase, current_user.email_address)
      # Filter params so employee can only update their own attendance
      attendances_params = attendances_params.slice(linked_emp&.id.to_s)
    end

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

    msg = employee? ? "Your attendance for #{date.strftime('%d %B %Y')} has been marked!" : "Attendance saved for #{date.strftime('%d %B %Y')}!"
    redirect_to bulk_attendances_path(date: date), notice: msg
  rescue => e
    redirect_to bulk_attendances_path(date: date), alert: "Error saving attendance: #{e.message}"
  end
end
