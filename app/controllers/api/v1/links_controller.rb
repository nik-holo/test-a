# frozen_string_literal: true

module Api
  module V1
    class LinksController < ApplicationController
      include Authenticatable

      ACCESS_LEVEL_REQUIRED = "admin".freeze

      # POST /links
      def create
        render json: upload_url, status: :created
      end

      private

      # Only allow a list of trusted parameters through.
      def link_params
        params.fetch(:link).require(:expires_at)
      end

      def upload_url
        token = JsonWebToken.encode({}, params[:expires_at])
        "#{request.base_url}/api/v1/images/upload/#{token}"
      end
    end
  end
end
