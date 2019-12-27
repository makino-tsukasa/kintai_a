class UsersController < ApplicationController
  before_action :set_user, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user, only: [:show, :edit, :update]
  before_action :superior_or_correct_user, only: :show
  # before_action :correct_user, only: [:edit, :update]
  before_action :admin_user, only: [:index, :index_working_on, :edit, :update, :destroy]
  before_action :except_admin_user, only: :show
  before_action :set_one_month, only: :show
  
  def index
    @users = User.paginate(page: params[:page]).where.not(id: 1)
  end
  
  def index_working_on
    @users = User.all.includes(:attendances)
  end
  
  def import
    # fileはtmpに自動で一時保存される
    if params[:file] == nil
      flash[:danger] = "インポートするCSVファイルを選択してください"
      redirect_to users_url
    else
      User.import(params[:file])
      redirect_to users_url
    end
  end
  
  def show
    @worked_sum = @attendances.where.not(started_at: nil).count
    respond_to do |format|
      format.html
      format.csv do
        send_data render_to_string, filename: "#{@user.name} 勤怠情報.csv", type: :csv
          #csv用の処理を書く
      end
    end
    @extrawork_request = Attendance.where(request_to: @user.id).where(status: 2).or(Attendance.where(request_to: @user.id).where(status: 4))
    @oneday_request = Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 2).or(Attendance.where(oneday_attendance_request_to: @user.id).where(oneday_attendance_status: 4))
    @monthly_request = Attendance.where(monthly_approvement_to: @user.id).where(monthly_approvement_status: 2).or(Attendance.where(monthly_approvement_to: @user.id).where(monthly_approvement_status: 4))
    @attendance = Attendance.find_by(user_id: params[:id], worked_on: @first_day)
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)
      if @user.save
        log_in @user 
        flash[:success] = "新規ユーザーの登録に成功しました。"
        redirect_to @user
      else
        render :new
      end
  end
  
  def edit
  end

  def update
    if @user.update_attributes(user_params)
      flash[:success] = "#{@user.name}のユーザー情報を編集しました。"
      redirect_to users_url
    else
      flash[:danger] = "誤った入力データがあった為、ユーザー情報の更新をキャンセルしました。"
      redirect_to users_url 
    end
  end
  
  def destroy
    @user.destroy
    flash[:success] = "#{@user.name}のデータを削除しました。"
    redirect_to users_url
  end


  private

    def user_params
      params.require(:user).permit(:name, :email, :affiliation, :employee_number, :uid,
                                   :basic_work_time,
                                   :designated_work_start_time, :designated_work_end_time,
                                   :password, :password_confirmation)
    end
end