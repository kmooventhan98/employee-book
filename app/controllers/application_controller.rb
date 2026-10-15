class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  # Changes to the importmap will invalidate the etag for HTML responses
  stale_when_importmap_changes

  helper_method :current_user, :current_business, :super_admin?, :admin?, :employee?

  private

  def current_user
    Current.user
  end

  def current_business
    if current_user&.super_admin?
      if session[:active_business_id].present?
        Business.find_by(id: session[:active_business_id]) || Business.first
      else
        Current.business || Business.first
      end
    else
      Current.business
    end
  end

  def super_admin?
    current_user&.super_admin?
  end

  def admin?
    current_user&.admin? || current_user&.super_admin?
  end

  def employee?
    current_user&.employee?
  end

  def require_admin
    unless admin?
      redirect_to root_path, alert: "Access restricted to Business Owners."
    end
  end

  def require_super_admin
    unless super_admin?
      redirect_to root_path, alert: "Access restricted to Platform Super Admin."
    end
  end
end
