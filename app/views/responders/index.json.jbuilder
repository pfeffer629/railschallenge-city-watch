json.responders @responders do |responder|
  json.extract! responder, :emergency_code, :type, :name, :capacity, :on_duty
end