class LvcDiscard < ActiveRecord::Base
	has_many :lvc_discard_details
	belongs_to :create_user, class_name: 'User'
	belongs_to :checked_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'

	STATUS = { checking: 'checking', declined: 'declined', done: 'done' }

	def status_name
	  status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
	end

	def self.do_discard(atype, select_infos, user)
		lvc_discard = LvcDiscard.create name: "报废单#{Time.now.strftime("%Y%m%d")}", status: "checking", create_user_id: user.id, create_unit_id: user.unit_id, atype: atype

    select_infos.each do |id|
    	if atype.eql? "lvc"
      	lvc_discard.lvc_discard_details.create low_value_consumption_info_id: id.to_i
      elsif atype.eql? "rent"
      	lvc_discard.lvc_discard_details.create rent_info_id: id.to_i
      end
    end
	end
end
