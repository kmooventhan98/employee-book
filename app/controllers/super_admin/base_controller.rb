module SuperAdmin
  class BaseController < ApplicationController
    before_action :require_super_admin
    layout "application"
  end
end
