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
    return if severity == 0
    @responders = Responder.where(type: type, on_duty: true).order(capacity: :asc)
    return if send_all_responders?(emergency, severity)
    return if dispatch_single_responder?(emergency, severity)
    dispatch_multiple_responders(emergency, severity)
  end

  def self.send_all_responders?(emergency, severity)
    total_capacity = @responders.sum(:capacity)

    emergency.responders.push(*@responders) if total_capacity <= severity
    emergency.update(full_response: false) if total_capacity < severity
  end

  def self.dispatch_single_responder?(emergency, severity)
    emergency.responders << @responders.first if @responders.length == 1
    emergency.responders << @responders.find_by(capacity: severity) unless @responders.find_by(capacity: severity).nil?
  end

  def self.dispatch_multiple_responders(emergency, severity)
    find_combination(severity)
    emergency.responders.push(*@allocation)
  end

  def self.find_combination(severity)
    @best_total = 0
    @allocation = []

    # find all possible responder combinations
    @responders.length.times do |i|
      possible_combinations = @responders.combination(i + 1).to_a
      possible_combinations.each do |combination|
        find_combination_capacity(combination)
        break if equivalent_combination(combination, severity)
        # stops loop if current combination is > best total
        # because combination totals are increasing
        break if @combination_capacity > @best_total && @combination_capacity > severity
        find_optimal_allocation(combination)
      end
    end
  end

  def self.find_combination_capacity(combination)
    # find total of each combination
    @combination_capacity = 0
    combination.map { |responder| @combination_capacity += responder.capacity }
    @combination_capacity
  end

  def self.equivalent_combination(combination, severity)
    @allocation = combination if @combination_capacity == severity
  end

  def self.find_optimal_allocation(combination)
    if @combination_capacity < @best_total
      @best_total = @combination_capacity
      @allocation = combination
    end
  end
end
