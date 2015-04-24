class Responder < ActiveRecord::Base
  belongs_to :emergency

  self.inheritance_column = nil
  validates :name, uniqueness: true
  validates :type, :name, :capacity, presence: true
  validates :capacity, inclusion: { in: (1..5) }

  def as_json(_options)
    {
      emergency_code: emergency_code,
      type: type,
      name: name,
      capacity: capacity,
      on_duty: on_duty
    }
  end
end
