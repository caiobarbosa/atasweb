class Patient < ActiveRecord::Base
  belongs_to :user
  belongs_to :health_plan
  belongs_to :supply_area

  has_many :sensors, dependent: :destroy

  validates :name, :health_plan, :supply_area, :order_number, :o2_prescription, :period, presence: true

  enum period: { "Continuo": 0, "Se necessario": 1 }
end
