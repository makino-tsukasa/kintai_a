class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :edit_extrawork_request, :update_extrawork_request,
                                  :edit_approve_extrawork_request, :edit_approve_oneday_request, :approved_request]
  before_action :logged_in_user, only: [:update, :edit_one_month]
  before_action :set_one_month, only: :edit_one_month
  
  UPDATE_ERROR_MSG = "勤怠登録に失敗しました。やり直してください。"
  
  def update
    @user = User.find(params[:user_id])
    @attendance = Attendance.find(params[:id])
    if @attendance.started_at.nil?
      if @attendance.update_attributes(started_at: Time.current.change(sec: 0))
        @attendance.first_started_at = @attendance.started_at
        @attendance.save
        flash[:info] = "おはようございます！"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    elsif @attendance.finished_at.nil?
      if @attendance.update_attributes(finished_at: Time.current.change(sec: 0))
        @attendance.first_finished_at = @attendance.finished_at
        @attendance.save
        flash[:info] = "お疲れ様でした。"
      else
        flash[:danger] = UPDATE_ERROR_MSG
      end
    end
    redirect_to @user
  end
  
  def edit_one_month
  end
  
  # 一ヶ月分の勤怠編集ページから一日分の申請をする
  def update_one_month
    ActiveRecord::Base.transaction do
      attendances_params.each do |id, item|
        attendance = Attendance.find(id)
        
        n = attendance.id.to_s
        if params[:user][:attendances][n][:oneday_attendance_request_to].present?
          attendance.update_attributes!(item)
          attendance.oneday_attendance_status = "申請中"
          attendance.request_started_at = attendance.request_started_at.change(year: attendance.worked_on.year,
                                                                               month: attendance.worked_on.month,
                                                                               day: attendance.worked_on.day)
          attendance.request_finished_at = attendance.request_finished_at.change(year: attendance.worked_on.year,
                                                                                 month: attendance.worked_on.month,
                                                                                 day: attendance.worked_on.day)
          if params[:user][:attendances][n][:next_day] == "1"
            attendance.request_finished_at = attendance.request_finished_at.tomorrow
          end
        end
        attendance.save
      end
    end
  flash[:success] = "勤怠編集を申請しました。"
  redirect_to user_url(date: params[:date])
  
  rescue ActiveRecord::RecordInvalid
    flash[:danger] = "無効な入力データがあった為、更新をキャンセルしました。"
    redirect_to attendances_edit_one_month_user_url(date: params[:date])
  end

  # 残業申請
  def edit_extrawork_request
    @attendance = @user.attendances.find(params[:format])
  end
  
  def update_extrawork_request
    @attendance = Attendance.find(params[:format])
    if @attendance.update_attributes(extrawork_params)
      @attendance.status = "申請中"
      @attendance.redesignated_endtime = @user.designated_work_end_time.change(year: @attendance.worked_on.year,
                                                                               month: @attendance.worked_on.month,
                                                                               day: @attendance.worked_on.day)
      @attendance.expecting_finish_time = @attendance.expecting_finish_time.change(year: @attendance.worked_on.year,
                                                                                   month: @attendance.worked_on.month,
                                                                                   day: @attendance.worked_on.day)
      if params[:attendance][:next_day] == '1'
        @attendance.expecting_finish_time = @attendance.expecting_finish_time.tomorrow
      end
      @attendance.save
      flash[:success] = "残業申請を登録しました。"
    end
    redirect_to user_url(@user)
  end
  
  # 残業申請の承認（上長）
  def edit_approve_extrawork_request
    @attendances = Attendance.where(request_to: @user.id).where(status: 2).or(Attendance.where(request_to: @user.id).where(status: 4))
    requested_from = @attendances.pluck(:user_id) | @attendances.pluck(:user_id)
    @users = User.find(requested_from)
  end
  
  def update_approve_extrawork_request
    ActiveRecord::Base.transaction do
      approve_extrawork_request_params.each do |id, item|
        attendance = Attendance.find(id)
        n = attendance.id.to_s
        if params[:attendances][n][:approve] == "1"  
          attendance.update_attributes!(item)
        end
      end
    end
    flash[:success] = "残業申請を更新しました。"
    redirect_to user_url
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "残業申請の更新をキャンセルしました。"
    redirect_to user_url
  end
  
  # 一日分の勤怠変更承認（上長）
  def edit_approve_oneday_request
    @attendances = Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 2).or(Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 4))
    requested_from = @attendances.pluck(:user_id) | @attendances.pluck(:user_id)
    @users = User.find(requested_from)
  end
  
  def update_approve_oneday_request
    ActiveRecord::Base.transaction do
      approve_oneday_request_params.each do |id, item|
        attendance = Attendance.find(id)
        n = attendance.id.to_s
        if params[:attendances][n][:approve] == "1"  
          attendance.update_attributes!(item)
          if attendance.oneday_attendance_status == "承認"
            attendance.started_at = attendance.request_started_at
            attendance.finished_at = attendance.request_finished_at
            attendance.date_of_approvement = DateTime.current
            attendance.save
          end
        end
      end
    end
    flash[:success] = "勤怠変更申請を更新しました。"
    redirect_to user_url
    
  rescue ActiveRecord::RecordInvalid # トランザクションによるエラーの分岐です。
    flash[:danger] = "勤怠変更申請の更新をキャンセルしました。"
    redirect_to user_url
  end
  
  # 勤怠修正ログ
  def approved_request
    @attendances = Attendance.where(user_id: @user.id).where(oneday_attendance_status: 3)
  end
  
  private
    # 1ヶ月分の勤怠情報を扱います。
    def attendances_params
      params.require(:user).permit(attendances: [:request_started_at, :request_finished_at,
                                                 :note, :oneday_attendance_request_to])[:attendances]
    end
    
    def extrawork_params
      params.require(:attendance).permit([:expecting_finish_time, :details_of_tasks, 
                                          :request_to, :status, :redesignated_endtime])
    end
    
    def approve_extrawork_request_params
      params.permit(attendances: [:status])[:attendances]
    end
    
    def approve_oneday_request_params
      params.permit(attendances: [:oneday_attendance_status, :approve])[:attendances]
    end
end