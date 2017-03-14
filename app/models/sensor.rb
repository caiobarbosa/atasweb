class Sensor < ActiveRecord::Base
  has_many :pressures, dependent: :destroy

  belongs_to :user

  belongs_to :patient

  validates :name, :token, :capacity, :patient, presence: true

  enum capacity: { "3L": 3.0, "3.7L": 3.7, "5L": 5.0, "20L": 20.0, "33L": 33.0, "40L": 40.0 }
end
