class Message < ActiveRecord::Base
	has_many :user_messages, dependent: :destroy
	belongs_to :activate_asset

	def self.select_years
	  years = []
	  i=2021

	  current_year = Time.now.year
	  while i<=(current_year+5)
	  	years << i
	  	i +=1
	  end
	  
	  return years
	end

	def unread_unit_names
		unread_unit_name = []
		read_same_units = []

		read_units = Unit.joins(:users).joins(:users=>[:user_messages]).where("(units.unit_level=? or units.is_facility_management_unit = ?) and user_messages.message_id = ? and user_messages.is_read = ?", 2, true, self.id, true)
		read_units_count = read_units.count
		read_units.where("same_unit_no is not null").each do |x|
			read_same_units << I18n.t("same_unit_no").key(x.same_unit_no)
		end

		if read_units.count == 0
			unread_unints = Unit.where("unit_level=? or is_facility_management_unit = ?", 2,true)
		else
			unread_unints = Unit.where("unit_level=? or is_facility_management_unit = ?", 2,true).where.not("id in (?)", read_units.map{|u| u.id})
		end

		unread_unints.each do |x|
			if !x.same_unit_no.nil? 
				unread_unit_name << I18n.t("same_unit_no").key(x.same_unit_no) 
			else 
				unread_unit_name << x.print_unit_name
			end
		end
		unread_unit_names = (unread_unit_name.uniq - read_same_units.uniq).compact.join(",")

		return [read_units_count, unread_unit_names]
	end

end
