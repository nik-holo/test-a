# frozen_string_literal: true

class Image < ApplicationRecord # rubocop:disable Style/Documentation
  has_one_attached :image
end
