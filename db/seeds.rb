Coach.find_or_create_by!(email: "hickoryshuttleworth@gmail.com") do |coach|
  coach.firstname = "Hick"
  coach.lastname = "Shuttleworth"
  coach.password = "Letmein123"
  coach.password_confirmation = "Letmein123"
end
