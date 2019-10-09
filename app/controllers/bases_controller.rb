class BasesController < ApplicationController
  
  def index
    @bases = Base.all
  end
  
  def new
    @base = Base.new
  end
  
  def create
    @base = Base.new(base_params)
    if @base.save
      flash[:success] = "拠点情報を追加しました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点情報を追加できませんでした。"
      redirect_to bases_url
    end
  end
    
  def destroy
    @base = Base.find(params[:id])
    if @base.destroy
      flash[:success] = "拠点情報を削除しました。"
      redirect_to bases_url
    else
      render :index
    end
  end
  
  def edit
    @base = Base.find(params[:id])
  end
  
  def update
    @base = Base.find(params[:id])
    if @base.update_attributes(base_params)
      flash[:success] = "拠点情報を修正しました。"
      redirect_to bases_url
    else
      flash[:danger] = "拠点情報を修正することができませんでした。"
      redirect_to bases_url
    end
  end
  
  
  private
  
    def base_params
      params.require(:base).permit(:base_number, :base_name, :type_of_attendance)
    end
end
