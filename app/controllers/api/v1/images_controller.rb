# frozen_string_literal: true

module Api
  module V1
    class ImagesController < ApplicationController
      include Authenticatable

      ACCESS_LEVEL_REQUIRED = "uploader".freeze

      before_action :set_image, only: %i[show update destroy]

      # GET /images
      def index
        @images = Image.all

        render json: @images
      end

      # GET /images/1
      def show
        # in real world this would redirect to S3 probably or wherever it's stored for real
        redirect_to url_for(@image.image.blob)
      end

      # POST /images
      def create
        response = []
        errors = []

        files = params[:files]

        files&.each do |image|
          @image = Image.new
          @image.image = image
          @image.uuid = SecureRandom.uuid
          @image.checksum = @image.image.blob.checksum

          @image.save
          response << @image.uuid
          ::StatsService.save_stats(url_for(@image.image.blob), @image.image.blob.content_type)
        rescue ActiveRecord::RecordNotUnique => e
          response << "duplicate image: #{@image.image.blob.filename}"
        end

        if errors.blank?
          render json: response, status: :created
        else
          render json: errors, status: :unprocessable_entity
        end
      end

      # PATCH/PUT /images/1
      def update
        if @image.update(image_params)
          render json: @image
        else
          render json: @image.errors, status: :unprocessable_entity
        end
      end

      # DELETE /images/1
      def destroy
        @image.destroy
      end

      private

      # Use callbacks to share common setup or constraints between actions.
      def set_image
        @image = Image.find_by(uuid: params[:uuid])
      end

      # Only allow a list of trusted parameters through.
      def image_params
        params.fetch(:image, {}).permit(files: [])
      end
    end
  end
end
