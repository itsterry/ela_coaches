FactoryBot.define do
  factory :availability do
    coach
    date { Date.current + 1.week }
    start_time { "09:00" }
    finish_time { "12:00" }
    slot_length { 30 }
    zoom { false }
    status { "draft" }

    trait :published do
      status { "published" }
    end
  end
end
