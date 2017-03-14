class TemperaturesController < ApplicationController
  include TemperatureAuthenticable

  before_action :authenticate_with_token!, only: [:create]

  def index
    @sensor = TemperatureSensor.find_by(id: params[:sensor_id])


    @temperatures = @sensor.temperatures.order(created_at: :desc)
  end

  def create
    @temperature = current_sensor.temperatures.create!(temperature_params)
    PrivatePub.publish_to("/temperatures/#{current_sensor.user.id}/new", temperature: @temperature.show_line)
    puts params
    render nothing: true
  end

  private

  def temperature_params
    params.require(:temperature).permit(:value, :humidity, :status_door)
  end
end

