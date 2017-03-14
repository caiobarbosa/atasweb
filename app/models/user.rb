class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  devise :database_authenticatable,
         :rememberable, :trackable, :validatable

  has_many :sensors, dependent: :destroy
  has_many :temperature_sensors, dependent: :destroy

  has_many :patients, dependent: :destroy

  validates :name, presence: true

  def my_sensors
    sensors = []
    self.sensors.each do |sensor|
      pressure = sensor.pressures.last
      sensors << {sensor: {name: sensor.name, pressure: {value: pressure.value, spent: pressure.spent}}}
    end
    sensors
  end
end
