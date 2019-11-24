class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :edit_extrawork, :update_extrawork]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        attendance.update_attributes!(item)
      end
    end
  flash[:success] = "1ヶ月分の勤怠情報を更新しました。"
  redirect_to user_url(date: params[:date])
  
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  def edit_extrawork
    @attendance = @user.attendances.find_by(id: params[:format])
  end
  
  def update_extrawork
    @attendance = Attendance.find_by(worked_on: params[:worked_on])
    if @attenadnce.update_attributes(extrawork_params)
      flash[:success] = "残業申請を登録しました。"
      redirect_to users_url
    end
  end
  
  
  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:started_at, :finished_at, :note])[:attendances]
    end
    
    def extrawork_params
      params.require(:user).permit(attendances: [:expecting_finishtime, :details_of_tasks, :request_to, :status])
    end
end
