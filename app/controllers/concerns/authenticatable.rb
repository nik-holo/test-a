# This is common module to authenticate users.
module Authenticatable
  extend ActiveSupport::Concern

  included do
    before_action :authenticate!
  end

  private

  def authenticate!
    bearer_token = request.headers["Authorization"]&.delete_prefix("Bearer ") || params[:token]
    decoded_json = JsonWebToken.decode(bearer_token)

    forbidden if decoded_json["role"] != self.class::ACCESS_LEVEL_REQUIRED
  end

  def forbidden
    render status: :forbidden
  end
end
