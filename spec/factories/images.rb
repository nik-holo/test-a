# frozen_string_literal: true

FactoryBot.define do
  factory :image do
    uuid { "MyText" }
    checksum { Faker::Alphanumeric.alphanumeric(number: 32) }
  end
end
