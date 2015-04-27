class Response
  def self.response_count
    enough_personnel = Emergency.where(full_response: true).count
    total_emergencies = Emergency.all.count
    [enough_personnel, total_emergencies]
  end

  def self.response_message
    "#{response_count[0]} out of #{response_count[1]} emergencies had enough personnel."
  end
end
