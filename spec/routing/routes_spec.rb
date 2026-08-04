RSpec.describe "routes", type: :routing do
  route_check "/", "availabilities", "index"
  route_check "/session/new", "sessions", "new"
  route_check "/up", "rails/health", "show"

  route_check_resource "/coaches/availabilities", "coaches/availabilities"

  route_check_resource "/cancellations", "cancellations", {}, %i[show destroy], :uuid

  route_check_resource "/coaches/slots", "coaches/slots", {}, %i[destroy]

  route_check_resource "/availabilities/1/bookings",
                       "bookings",
                       { availability_id: "1" },
                       %i[new create]
end
