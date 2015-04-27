class Capacity
  def self.display_capacity
    @capacity = {
      'Fire' => [0, 0, 0, 0],
      'Police' => [0, 0, 0, 0],
      'Medical' => [0, 0, 0, 0]
    }
    calculate_capacity
    @capacity
  end

  def self.calculate_capacity
    Responder.find_each do |responder|
      next if responder_ready?(responder)
      next if responder_on_duty?(responder)
      next if responder_available?(responder)
      responder_total?(responder)
    end
  end

  def self.responder_ready?(responder)
    if !responder.emergency_code? && responder.on_duty == true
      @capacity["#{responder.type}"].map! { |total| total + responder.capacity }
    end
  end

  def self.responder_on_duty?(responder)
    if responder.on_duty
      @capacity["#{responder.type}"][2] += responder.capacity
      @capacity["#{responder.type}"][0] += responder.capacity
    end
  end

  def self.responder_available?(responder)
    unless responder.emergency_code?
      @capacity["#{responder.type}"][1] += responder.capacity
      @capacity["#{responder.type}"][0] += responder.capacity
    end
  end

  def self.responder_total?(responder)
    @capacity["#{responder.type}"][0] += responder.capacity
  end
end
