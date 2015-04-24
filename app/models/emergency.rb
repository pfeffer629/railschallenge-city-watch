class Emergency < ActiveRecord::Base
  has_many :responders, foreign_key: :emergency_code, primary_key: :code

  validates :code, uniqueness: true
  validates :code, :fire_severity, :police_severity, :medical_severity, presence: true
  validates :fire_severity, :police_severity, :medical_severity, numericality: { greater_than_or_equal_to: 0 }

  def as_json(_options)
    {
      code: code,
      fire_severity: fire_severity,
      police_severity: police_severity,
      medical_severity: medical_severity,
      resolved_at: resolved_at
    }
  end
end
