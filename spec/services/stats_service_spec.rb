# frozen_string_literal: true

describe StatsService do
  it 'should have a valid factory' do
    FactoryBot.create(:image).should be_valid
  end

  describe '.stats_report' do
    it 'should return the stats' do
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      FactoryBot.create(:image, uuid: '1234')
      stats = StatsService.stats_report
      expect(stats[:total_images]).to eq(16)
    end
  end
end
