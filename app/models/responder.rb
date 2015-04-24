class Responder < ActiveRecord::Base
  belongs_to :emergency

  self.inheritance_column = nil
  validates :name, uniqueness: true
  validates :type, :name, :capacity, presence: true
  validates :capacity, inclusion: { in: (1..5) }

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
    responders = Responder.where(type: type, on_duty: true).order(capacity: :desc)

    if send_all_responders?(emergency, responders, severity)
      return
    else
      calculate_allocation(responders, severity)
      emergency.responders.push(*@allocation)
    end
  end

  def self.send_all_responders?(emergency, responders, severity)
    total = 0

    # if severity > total capacity, send all responders
    responders.each do |responder|
      total += responder.capacity
    end

    # send all responders if capacity < severity
    if total < severity
      emergency.update(full_response: false)
      emergency.responders.push(*responders)
      return true
    # send all responders if capcity = severity
    elsif total == severity
      emergency.responders.push(*responders)
      return true
    elsif responders.length == 1
      # send all responders if only 1 responder
      emergency.responders.push(responders.first)
      return true
    else
      return false
    end
  end

  def self.calculate_allocation(responders, severity)
    @best_total = 0
    @allocation = []

    # find all possible responder combinations
    responders.length.times do |i|
      possible_combinations = responders.combination(i + 1).to_a
      possible_combinations.each do |combination|
        find_combination_total(combination)
        find_optimal_allocation(combination, @combination_total, severity)
      end
    end
  end

  def self.find_combination_total(combination)
    # find total of each combination
    @combination_total = 0
    combination.each do |responder|
      @combination_total += responder.capacity
    end
    @combination_total
  end

  def self.find_optimal_allocation(combination, total, severity)
    # find combination that is equal to severity
    if total == severity
      @allocation = combination
      return @allocation
    end
    # find lowest combination that is higher than severity
    if total > severity && total < @best_total
      @best_total = total
      @allocation = combination
    end
  end
end
