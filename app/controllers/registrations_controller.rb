class RegistrationsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
    redirect_to new_session_path, alert: "Public self-registration is closed. Please contact the Platform Super Admin to onboard your business."
  end

  def create
    redirect_to new_session_path, alert: "Public self-registration is closed. Please contact the Platform Super Admin to onboard your business."
  end
end
