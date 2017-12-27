class LvcDiscardDetail < ActiveRecord::Base
	belongs_to :lvc_discard
	belongs_to :low_value_consumption_info
end
