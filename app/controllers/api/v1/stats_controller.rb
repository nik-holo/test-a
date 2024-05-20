# frozen_string_literal: true

module Api
  module V1
    class StatsController < ApplicationController
      include Authenticatable

      ACCESS_LEVEL_REQUIRED = "admin".freeze

      before_action :generate_stats, only: %i[index]

      def index
        render json: @stats, status: :ok
      end

      private

      def generate_stats
        @stats ||= ::StatsService.stats_report
      end
    end
  end
end
