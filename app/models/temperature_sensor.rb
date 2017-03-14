class TemperatureSensor < ActiveRecord::Base
  belongs_to :user

  has_many :temperatures, dependent: :destroy

  enum sensor_kind: { Ambiente: 0, Refrigerador: 1 }
end
