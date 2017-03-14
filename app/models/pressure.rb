class Pressure < ActiveRecord::Base
  belongs_to :sensor

  validates :value, :spent, presence: true

  def show_line
    {sensor: self.sensor, pressure: {value: self.value, spent: calc_spent, estimate: calc_estimate}}
  end

  def calc_spent
    self.spent.to_s.to_d * Sensor.capacities[self.sensor.capacity]
  end

  private

  def calc_estimate
    capacity = Sensor.capacities[self.sensor.capacity]
    pressure = self.value.to_s.to_d
    spent = calc_spent

    hours = (capacity * pressure) / (spent * 60)
    total_seconds = hours * 3600

    if spent == 0
      "00:00"
    else
      #seconds = total_seconds % 60
      minutes = (total_seconds / 60) % 60
      hours = total_seconds / (60 * 60)

      #format("%02d:%02d:%02d", hours, minutes, seconds)
      format("%02dh %02dmin", hours, minutes)
    end
  end

end
