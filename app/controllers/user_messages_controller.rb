class UserMessagesController < ApplicationController
  before_action :set_user_message, only: [:show, :edit, :update, :destroy]

  def index
    @user_messages = UserMessage.all
    respond_with(@user_messages)
  end

  def show
    respond_with(@user_message)
  end

  def new
    @user_message = UserMessage.new
    respond_with(@user_message)
  end

  def edit
  end

  def create
    @user_message = UserMessage.new(user_message_params)
    @user_message.save
    respond_with(@user_message)
  end

  def update
    @user_message.update(user_message_params)
    respond_with(@user_message)
  end

  def destroy
    @user_message.destroy
    respond_with(@user_message)
  end

  def set_is_read
    if !params[:message_id].blank?
      UserMessage.where("message_id in (?) and user_id = ?", params[:message_id].split(",").map(&:to_i), current_user.id).each do |x|
        x.update is_read: true
      end
    end
  end

  private
    def set_user_message
      @user_message = UserMessage.find(params[:id])
    end

    def user_message_params
      params[:user_message]
    end
end
