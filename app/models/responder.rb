class Responder < ActiveRecord::Base
  belongs_to :emergency

  self.inheritance_column = nil
  validates :name, uniqueness: true
  validates :type, :name, :capacity, presence: true
  validates :capacity, inclusion: { in: (1..5) }

  def self.dispatch_responders(emergency)
    responders = Responder.all
    calculate_responders(emergency, "Fire", emergency.fire_severity)
    calculate_responders(emergency, "Police", emergency.police_severity)
    calculate_responders(emergency, "Medical", emergency.medical_severity)
  end

  def self.calculate_responders(emergency, type, severity)
    if severity_0?(severity)
      return
    elsif single_responder?(emergency, type, severity)
      return
    else
      multiple_responders?(emergency, type, severity)
    end
  end

  def self.severity_0?(severity)
    if severity == 0
      return true
    end
  end

  def self.single_responder?(emergency, type, severity)
    responders = Responder.where(type: type, on_duty: true).order(capacity: :desc)
    responders.each do |responder|
      if responder.capacity == severity
        emergency.responders << responder
        return true
      end
    end
    return false
  end

  def self.multiple_responders?(emergency, type, severity)
    responders = Responder.where(type: type, on_duty: true).order(capacity: :desc)
    best_total = 0
    allocation = []

    for i in (0..responders.length)
      possible_combinations = responders.combination(i).to_a
      possible_combinations.each do |combination|
        combination_total = 0
        combination.each do |responder|
          combination_total += responder.capacity
        end
        if best_total == severity
          allocation << combination
          break
        elsif best_total < severity
          if combination_total > best_total
            best_total = combination_total
            allocation << combination
          end
        else
          if combination_total < best_total
            best_total = combination_total
            allocation << combination
          end
        end
        allocation.each do |responder|
          emergency.responders << responder
        end
      end
    end
  end
end
