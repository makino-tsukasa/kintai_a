class StaticPagesController < ApplicationController
  before_action :admin_user, only: :edit_system_info
  
  def top
  end
  
  def edit_system_info
  end
end