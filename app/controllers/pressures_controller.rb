class PressuresController < ApplicationController
  include Authenticable

  before_action :authenticate_with_token!, only: [:create]

  def index
    @sensor = Sensor.find_by(id: params[:sensor_id])


    @pressures = @sensor.pressures.where(created_at: Date.today.beginning_of_day..Date.today.end_of_day).order(created_at: :desc)
  end

  def create
    @pressure = current_sensor.pressures.create!(pressure_params)
    PrivatePub.publish_to("/pressures/#{current_sensor.user.id}/new", pressure: @pressure.show_line)
    render nothing: true
  end

  private

  def pressure_params
    params.require(:pressure).permit(:value, :spent)
  end
end
