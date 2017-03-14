module TemperatureAuthenticable

  def current_sensor
    @current_sensor ||= TemperatureSensor.find_by(token: request.headers['Authorization'])
  end

  def authenticate_with_token!
    render json: { errors: "Not authenticated" },
                status: :unauthorized unless sensor_exists?
  end

  def sensor_exists?
    current_sensor.present?
  end
end

