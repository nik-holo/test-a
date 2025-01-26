# frozen_string_literal: true

describe ::Image do
  it 'is valid factory' do
    FactoryBot.create(:image).should be_valid
  end
end
