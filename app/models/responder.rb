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
    find_responders_of_type(type)
    # dispatch no responders if severity == 0
    if severity_0?(severity)
      return
    # dispatch single responder if responder capacity == 0
    # or if only 1 responder available
    elsif dispatch_single_responder?(emergency, severity)
      return
    # dispatch responders if multiple responders available,
    else
      dispatch_multiple_responders(emergency, severity)
    end
  end

  def self.find_responders_of_type(type)
    @responders = Responder.where(type: type, on_duty: true).order(capacity: :asc)
  end

  def self.severity_0?(severity)
    true if severity == 0
  end

  def self.dispatch_single_responder?(emergency, severity)
    if @responders.length == 1
      emergency.responders << @responders.first
    else
      @responders.each do |responder|
        if responder.capacity == severity
          emergency.responders << responder
          return true
        end
      end
    end
    false
  end

  def self.dispatch_multiple_responders(emergency, severity)
    # if total capacity of responders <= severity
    # send all responders
    if send_all_responders?(emergency, severity)
      return
    else
      calculate_allocation(severity)
      emergency.responders.push(*@allocation)
    end
  end

  def self.send_all_responders?(emergency, severity)
    max_capacity = calculate_max_capacity(@responders)

    # send all responders if capacity < severity
    if max_capacity < severity
      emergency.update(full_response: false)
      emergency.responders.push(*@responders)
      return true
    # send all responders if capcity == severity
    elsif max_capacity == severity
      emergency.responders.push(*@responders)
      return true
    else
      return false
    end
  end

  def self.calculate_max_capacity(responders)
    max_capacity = 0
    responders.each do |responder|
      max_capacity += responder.capacity
    end
    max_capacity
  end

  def self.calculate_allocation(severity)
    @best_total = 0
    @allocation = []

    # find all possible responder combinations
    @responders.length.times do |i|
      possible_combinations = @responders.combination(i + 1).to_a
      possible_combinations.each do |combination|
        find_combination_total(combination)
        find_optimal_allocation(combination, severity)
      end
    end
  end

  def self.find_combination_total(combination)
    # find total of each combination
    @combination_capacity = calculate_max_capacity(combination)
    @combination_capacity
  end

  def self.find_optimal_allocation(combination, severity)
    # find combination that is equal to severity
    if @combination_capacity == severity
      @allocation = combination
      return @allocation
    end
    # find lowest combination that is higher than severity
    if @combination_capacity > severity && @combination_capacity < @best_total
      @best_total = @combination_capacity
      @allocation = combination
    end
  end
end
