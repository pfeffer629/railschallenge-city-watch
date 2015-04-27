class Capacity
  def self.display_capacity
    @capacity = {
      'Fire' => [0, 0, 0, 0],
      'Police' => [0, 0, 0, 0],
      'Medical' => [0, 0, 0, 0]
    }
    Responder.find_each do |responder|
      calculate_capacity(responder)
      @capacity["#{responder.type}"][0] += responder.capacity
    end
    @capacity
  end

  def self.calculate_capacity(responder)
    return if responder_ready?(responder)
    return @capacity["#{responder.type}"][2] += responder.capacity if responder.on_duty?
    return @capacity["#{responder.type}"][1] += responder.capacity unless responder.emergency_code?
  end

  def self.responder_ready?(responder)
    if !responder.emergency_code? && responder.on_duty == true
      @capacity["#{responder.type}"].map! { |total| total + responder.capacity }
      @capacity["#{responder.type}"][0] -= responder.capacity
    end
  end
end
