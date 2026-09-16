class AvailabilitiesController < ApplicationController
  before_action :set_availability, only: %i[edit update destroy]

  def index
    @availabilities = current_user.availabilities.order(start_at: :asc)
  end

  def new
    @availability = current_user.availabilities.new
  end

  def create
    @availability = current_user.availabilities.new(availability_params)
    if @availability.save
      redirect_to availabilities_path, notice: "予定を登録しました"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @availability.update(availability_params)
      redirect_to availabilities_path, notice: "予定を更新しました"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @availability.destroy
    redirect_to availabilities_path, notice: "予定を削除しました"
  end

  private

  def set_availability
    @availability = current_user.availabilities.find(params[:id])
  end

  def availability_params
    params.require(:availability).permit(:start_at, :end_at, :note)
  end
end
