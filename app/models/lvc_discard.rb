class LvcDiscard < ActiveRecord::Base
	has_many :lvc_discard_details
	belongs_to :create_user, class_name: 'User'
	belongs_to :checked_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'

	STATUS = { checking: 'checking', declined: 'declined', done: 'done' }

	def status_name
	  status.blank? ? "" : self.class.human_attribute_name("status_#{status}")
	end
end
