json.emergencies @emergencies do |emergency|
  json.extract! emergency, :code, :fire_severity, :medical_severity, :police_severity, :resolved_at
end