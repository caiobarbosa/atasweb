class TemperatureSensorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @temperature_sensors = @temperature_sensor = current_user.temperature_sensors
  end

  def new
    @temperature_sensor = current_user.temperature_sensors.new
  end

  def create
    @temperature_sensor = current_user.temperature_sensors.new temperature_sensor_params

    if @temperature_sensor.save
      redirect_to temperature_sensors_path
    else
      render :new
    end
  end

  def show
    @temperature_sensor = current_user.temperature_sensors.find(params[:id])
  end

  def edit
    @temperature_sensor = current_user.temperature_sensors.find(params[:id])
  end

  def update
    @temperature_sensor = current_user.temperature_sensors.find(params[:id])

    if @temperature_sensor.update_attributes temperature_sensor_params
      redirect_to temperature_sensors_path
    else
      render :edit
    end
  end

  def destroy
    #TODO
  end

  private

  def temperature_sensor_params
    params[:temperature_sensor][:sensor_kind] = params[:temperature_sensor][:sensor_kind].to_i
    params.require(:temperature_sensor).permit(:name, :token, :sensor_kind)
  end
end

