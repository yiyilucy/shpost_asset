class Purchase < ActiveRecord::Base
	belongs_to :low_value_consumption_catalog
	has_many :low_value_consumption_infos

	
	STATUS = { waiting: 'waiting', checking: 'checking', declined: 'declined', canceled: 'canceled', done: 'done', revoked: 'revoked' }

	def status_name
	  status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
	end

	def is_send_name
	  if is_send
	    name = "是"
	  else
	    name = "否"
	  end
	end
end
