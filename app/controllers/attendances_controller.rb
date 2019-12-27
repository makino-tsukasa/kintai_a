class AttendancesController < ApplicationController
  before_action :set_user, only: [:edit_one_month, :edit_extrawork_request, :update_extrawork_request,
                                  :edit_approve_extrawork_request, :edit_approve_oneday_request, :approved_request,
                                  :monthly_request, :edit_approve_monthly_request, :update_approve_extrawork_request]
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
    attendances_params.each do |id, item|
      attendance = Attendance.find(id)
      n = attendance.id.to_s
      if params[:user][:attendances][n][:oneday_attendance_request_to].present?
        attendance.oneday_attendance_request_to = params[:user][:attendances][n][:oneday_attendance_request_to]
        attendance.note = params[:user][:attendances][n][:note]
        attendance.oneday_attendance_status = "申請中"
        if params[:user][:attendances][n][:request_started_at] != ""
          attendance.request_started_at = params[:user][:attendances][n][:request_started_at]
          attendance.request_started_at = attendance.request_started_at.change(year: attendance.worked_on.year,
                                                                               month: attendance.worked_on.month,
                                                                               day: attendance.worked_on.day)
        end
        if params[:user][:attendances][n][:request_finished_at] != ""
          attendance.request_finished_at = params[:user][:attendances][n][:request_finished_at]
          attendance.request_finished_at = attendance.request_finished_at.change(year: attendance.worked_on.year,
                                                                               month: attendance.worked_on.month,
                                                                               day: attendance.worked_on.day)
          if params[:user][:attendances][n][:next_day] == "1"
          attendance.request_finished_at = attendance.request_finished_at.tomorrow
          end
        end
        if attendance.save
          flash[:success] = "該当する勤務日の勤怠変更を申請しました。"
        else
          flash[:danger] = "無効な入力がされた勤務日の申請をキャンセルしました。"
        end
      else
        flash[:warning] = "所属長の選択がない勤務日は変更されません。"
      end
    end
    redirect_to user_url(date: params[:date])
  end

  # 残業申請
  def edit_extrawork_request
    @attendance = @user.attendances.find(params[:format])
  end
  
  def update_extrawork_request
    @attendance = Attendance.find(params[:format])
    if (params[:attendance][:request_to] == "上長ユーザー1") || (params[:attendance][:request_to] == "上長ユーザー2")
      @attendance.expecting_finish_time = params[:attendance][:expecting_finish_time]
      @attendance.expecting_finish_time = @attendance.expecting_finish_time.change(year: @attendance.worked_on.year,
                                                                                   month: @attendance.worked_on.month,
                                                                                   day: @attendance.worked_on.day)
      if params[:attendance][:next_day] == '1'
        @attendance.expecting_finish_time = @attendance.expecting_finish_time.tomorrow
      end
      @attendance.redesignated_endtime = @user.designated_work_end_time.change(year: @attendance.worked_on.year,
                                                                               month: @attendance.worked_on.month,
                                                                               day: @attendance.worked_on.day)
      @attendance.status = "申請中"
      @attendance.request_to = params[:attendance][:request_to]
      @attendance.details_of_tasks = params[:attendance][:details_of_tasks]
      if @attendance.save
        flash[:success] = "残業申請を登録しました。"
      else
        flash[:danger] = "無効な入力データがあった為、残業申請の登録をキャンセルしました。"
      end
    else
      flash[:danger] = "残業申請の登録には所属長の選択が必要です。"
    end
    redirect_to user_url(@user, @first_day)
  end
  
  # 残業申請の承認（上長）
  def edit_approve_extrawork_request
    @attendances = Attendance.where(request_to: @user.id).where(status: 2).or(Attendance.where(request_to: @user.id).where(status: 4))
    requested_from = @attendances.pluck(:user_id) | @attendances.pluck(:user_id)
    @users = User.find(requested_from)
  end
  
  def update_approve_extrawork_request
    approve_extrawork_request_params.each do |id, item|
    attendance = Attendance.find(id)
    n = attendance.id.to_s
      if params[:attendances][n][:approve] == "1"  
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "残業申請を更新しました。（更新は変更欄にチェックの入っている申請にのみ適用されます。）"
    redirect_to user_url
  end
  
  # 一日分の勤怠変更承認（上長）
  def edit_approve_oneday_request
    @attendances = Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 2).or(Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 4))
    requested_from = @attendances.pluck(:user_id) | @attendances.pluck(:user_id)
    @users = User.find(requested_from)
  end
  
  def update_approve_oneday_request
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
    flash[:success] = "勤怠変更申請を更新しました。（更新は変更欄にチェックの入っている申請にのみ適用されます。）"
    redirect_to user_url
  end
  
  # 勤怠修正ログ
  def approved_request
    @attendances = Attendance.where(user_id: @user.id).where(oneday_attendance_status: 3)
    @year = params[:year].to_i
    @month = params[:month].to_i
    search_month = "#{@year}-#{@month}-1"
    if params[:year].present? && params[:month] == "全ての月"
      search_month = "#{@year}-1-1"
      @attendances = @attendances.where(worked_on: search_month.in_time_zone.all_year)
    elsif params[:year].present? && params[:month].present?
      @attendances = @attendances.where(worked_on: search_month.in_time_zone.all_month)
    end
  end
  
  # 一ヶ月分の勤怠申請
  def monthly_request
    attendance = Attendance.find_by(user_id: params[:id], worked_on: params[:date])
      if (params[:monthly_approvement_to] == "上長ユーザー1") || (params[:monthly_approvement_to] == "上長ユーザー2")
        attendance.update_attributes(monthly_approvement_to: params[:monthly_approvement_to], monthly_approvement_status: "申請中")
        flash[:success] = "一ヶ月分の勤怠を申請しました。"
      else
        flash[:danger] = "所属長を選択してください。"
      end
    redirect_to @user
  end
  
  # 一ヶ月分の勤怠承認（上長）
  def edit_approve_monthly_request
    @attendances = Attendance.where(monthly_approvement_to: @user.id).where(monthly_approvement_status: 2).or(Attendance.where(monthly_approvement_to: @user.id).where(monthly_approvement_status: 4))
    requested_from = @attendances.pluck(:user_id) | @attendances.pluck(:user_id)
    @users = User.find(requested_from)
    
  end

  def update_approve_monthly_request
    approve_monthly_request_params.each do |id, item|
      attendance = Attendance.find(id)
      n = attendance.id.to_s
      if params[:attendances][n][:approve] == "1"  
        attendance.update_attributes!(item)
      end
    end
    flash[:success] = "所属長承認申請を更新しました。（更新は変更欄にチェックの入っている申請にのみ適用されます。）"
    redirect_to user_url
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
    
    def approve_monthly_request_params
      params.permit(attendances: [:monthly_approvement_status])[:attendances]
    end
end