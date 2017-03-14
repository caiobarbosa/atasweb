class Temperature < ActiveRecord::Base
  belongs_to :temperature_sensor

  def show_line
    {sensor: self.temperature_sensor, temperature: {value: self.value, humidity: self.humidity, status_door: show_status_door}}
  end

  def show_status_door
    if self.status_door == 1
      "Não"
    elsif self.status_door == 0
      "Sim"
    else
      nil
    end
  end

end
