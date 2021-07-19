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

end
