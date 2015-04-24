json.emergencies @emergencies do |emergency|
  json.code emergency.code
  json.fire_severity emergency.fire_severity
  json.medical_severity emergency.medical_severity
  json.police_severity emergency.police_severity
  json.resolved_at emergency.resolved_at
end

json.full_responses @response_count
