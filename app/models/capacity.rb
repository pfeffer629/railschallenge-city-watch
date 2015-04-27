class Capacity
  def self.display_capacity
    @capacity = {
      'Fire' => [0, 0, 0, 0],
      'Police' => [0, 0, 0, 0],
      'Medical' => [0, 0, 0, 0]
    }
    Responder.find_each do |responder|
      @capacity_type = @capacity["#{responder.type}"]
      @capacity_type[0] += responder.capacity
      calculate_capacity(responder)
    end
    @capacity
  end

  def self.calculate_capacity(responder)
    return @capacity_type[0] -= responder.capacity if responder_ready?(responder)
    return @capacity_type[2] += responder.capacity if responder.on_duty?
    return @capacity_type[1] += responder.capacity unless responder.emergency_code?
  end

  def self.responder_ready?(responder)
    if !responder.emergency_code? && responder.on_duty == true
      @capacity_type.map! { |total| total + responder.capacity }
    end
  end
end
