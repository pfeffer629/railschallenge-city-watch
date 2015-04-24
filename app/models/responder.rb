class Responder < ActiveRecord::Base
  belongs_to :emergency

  self.inheritance_column = nil
  validates :name, uniqueness: true
  validates :type, :name, :capacity, presence: true
  validates :capacity, inclusion: { in: (1..5) }

  private
  
  def self.dispatch_responders(emergency)
    allocate_responders(emergency, 'Fire', emergency.fire_severity)
    allocate_responders(emergency, 'Police', emergency.police_severity)
    allocate_responders(emergency, 'Medical', emergency.medical_severity)
  end

  def self.allocate_responders(emergency, type, severity)
    if severity_0?(severity)
      return
    elsif single_responder?(emergency, type, severity)
      return
    else
      multiple_responders?(emergency, type, severity)
    end
  end

  def self.severity_0?(severity)
    true if severity == 0
  end

  def self.single_responder?(emergency, type, severity)
    responders = Responder.where(type: type, on_duty: true).order(capacity: :desc)
    responders.each do |responder|
      if responder.capacity == severity
        emergency.responders << responder
        return true
      end
    end
    false
  end

  def self.multiple_responders?(emergency, type, severity)
    # find all responders available to respond to emergency
    responders = Responder.where(type: type, on_duty: true).order(capacity: :desc)
    # counter to find current best allocation of responders
    best_total = 0
    # array to store possible allocation of responders
    allocation = []

    # if severity > total capacity, send all responders
    responders.each do |responder|
      best_total += responder.capacity
    end

    # send all responders if only 1 or not enough responders
    if best_total <= severity
      emergency.responders.push(*responders)
    elsif responders.length == 1
      emergency.responders.push(responders.first)
    end

    # find all possible responder combinations
    responders.length.times do |i|
      possible_combinations = responders.combination(i + 1).to_a
      possible_combinations.each do |combination|
        combination_total = 0
        # find total of each combination
        combination.each do |responder|
          combination_total += responder.capacity
        end
        # find combination that is equal to severity
        if combination_total == severity
          allocation = combination
          break
        end
        # find highest combination that is lower than severity
        if best_total < severity
          if combination_total > best_total
            best_total = combination_total
            allocation = combination
          end
        end
        # find lowest combination that is higher than severity
        if combination_total > severity
          if combination_total < best_total
            best_total = combination_total
            allocation = combination
          end
        end
      end
      # set emergency responders equal to best found allocation
    end
    allocation.each do |responder|
      emergency.responders << responder
    end
  end

  def self.resolve_emergency(emergency)
    emergency.responders.clear
  end
end
