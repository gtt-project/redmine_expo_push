class ExpoPushTokensController < ApplicationController
  before_action :require_login
  accept_api_auth :create

  def create
    @token = ExpoPushToken.new user: User.current, token: params[:token]
    if @token.save
      respond_to do |format|
        format.api { head :created }
      end
    else
      respond_to do |format|
        format.api  { render_validation_errors(@token) }
      end
    end
  end
end
