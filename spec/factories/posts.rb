FactoryBot.define do
  factory :post do
    content { Faker::Lorem.sentence }
    title { Faker::Book.title }
    user
  end
  factory :invalid_post, parent: :post do
    title { nil }
    content { nil }
  end
end

