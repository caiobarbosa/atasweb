class Api::V1::AdmeasurementsController < ApiApplicationController
  respond_to :json

  before_action :authenticate_with_token!, only: [:create]

  def create
    pressure = current_sensor.pressures.new value: params[:value]

    if pressure.save
      render json: { status: "SUCCESS", pressure: pressure }, status: 201
    else
      render json: { status: "ERROR", errors: pressure.errors }, status: 422
    end
  end

  def show
    pressure = Pressure.last

    if pressure.present?
      render json: { status: "SUCCESS", pressure: pressure.value }, status: 201
    else
      render json: { status: "ERROR", errors: pressure.errors.value }, status: 422
    end
  end

  def index
    user = User.find(params[:user_id])
    pressures = user.sensors
    render json: { status: "SUCCESS", pressures: pressures }, status: 200
  end

  def index_temperatures
    user = User.find(params[:user_id])
    temperature_sensors = user.temperature_sensors
    render json: { status: "SUCCESS", temperature_sensors: temperature_sensors }, status: 200
  end

end

