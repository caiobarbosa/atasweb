class SensorsController < ApplicationController
  before_action :authenticate_user!

  def index
    @sensors = current_user.sensors
  end

  def new
    @sensor = Sensor.new
    @patients = current_user.patients
  end

  def create
    #patient = Patient.find params[:sensor][:patient_id]
    #@sensor = patient.sensors.new sensor_params
    @sensor = current_user.sensors.new sensor_params

    if @sensor.save
      redirect_to sensors_path
    else
      render :new
    end
  end

  def show
    @sensor = current_user.sensors.find(params[:id])
  end

  def edit
    @sensor = current_user.sensors.find(params[:id])
    @patients = current_user.patients
  end

  def update
    @sensor = current_user.sensors.find(params[:id])

    if @sensor.update_attributes sensor_params
      redirect_to sensors_path
    else
      render :edit
    end
  end

  def destroy
    @sensor = current_user.sensors.find(params[:id])

    if @sensor.destroy
      redirect_to sensors_path
    else
      render :show
    end

  end

  private

  def sensor_params
    params[:sensor][:capacity] = params[:sensor][:capacity].to_d
    params.require(:sensor).permit(:name, :token, :capacity, :patient_id)
  end
end
