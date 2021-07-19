class WelcomeController < ApplicationController
	before_action :create_user_message, only: [:index]

  def index
  	@messages = nil
  	if !current_user.unit.blank? && current_user.deviceadmin? && ((current_user.unit.unit_level==2) || current_user.unit.is_facility_management_unit)
  		@messages = Message.joins(:user_messages).where("user_messages.user_id = ? and  user_messages.is_read = ?", current_user.id, false).order("messages.created_at desc")
  	end
	end

	private
		def create_user_message
			if !current_user.unit.blank? && current_user.deviceadmin? && ((current_user.unit.unit_level==2) || current_user.unit.is_facility_management_unit)
				Message.joins(:activate_asset).where("activate_assets.status = ?", "valid").each do |m|
		      if UserMessage.where(message_id: m.id, user_id: current_user.id).blank?
		        UserMessage.create message_id: m.id, user_id: current_user.id
		      end
		    end
		  end
	  end
end
