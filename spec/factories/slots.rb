FactoryBot.define do
  factory :slot do
    availability
    parent_name { "Parent Name" }
    player_name { "Player Name" }
    start_time { availability&.start_time }
  end
end
