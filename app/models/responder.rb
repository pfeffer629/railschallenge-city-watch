class Responder < ActiveRecord::Base
  belongs_to :emergency

  self.inheritance_column = nil
  validates :name, uniqueness: true
  validates :type, :name, :capacity, presence: true
  validates :capacity, inclusion: { in: (1..5) }

  def self.dispatch_responders(emergency)
    responders = Responder.all
    calculate_responders(emergency, responders, "Fire", emergency.fire_severity)
    calculate_responders(emergency, responders, "Police", emergency.police_severity)
    calculate_responders(emergency, responders, "Medical", emergency.medical_severity)
  end

  def self.calculate_responders(emergency, responders, type, severity)
    responders = Responder.where(type: type).order(capacity: :desc)
    responders.each do |responder|
      if responder.capacity == severity
        emergency.responders << responder
      end
    end
    # else

    #     i = 1
    #     allocation = responders.combination(i)
        
    #     allocation.each do |new_combination|
    #       new_combination_sum = new_combination.reduce(:+)
    #       if new_combination_sum >= severity && new_combination_sum < allocation.reduce(:+)
    #         allocation = new_combination
    #       end
    #     end
    #     i += 1

    #   @answer = { responders: []}
  end
end
