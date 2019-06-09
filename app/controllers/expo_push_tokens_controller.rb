class ExpoPushTokensController < ApplicationController
  before_action :require_login
  accept_api_auth :create, :destroy_all

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

  def destroy_all
    user_id = params[:user_id].to_i if User.current.admin? and params[:user_id].present?
    user_id ||= User.current.id
    ExpoPushToken.where(user_id: user_id).delete_all
    respond_to do |format|
      format.api { head :ok }
      format.html {
        flash[:notice] = l(:notice_account_updated)
        redirect_to (User.current.admin? and user_id != User.current.id) ?
          edit_user_path(id: user_id) :
          my_account_path
      }
    end
  end
end
