class ActivateAsset < ActiveRecord::Base
	has_many :messages, dependent: :destroy
	belongs_to :create_user, class_name: 'User'
	belongs_to :create_unit, class_name: 'Unit'
	has_one :import_file
	validates_presence_of :contact, :tel, :introduce => '不能为空'

	STATUS = { valid: '有效', invalid: '失效', delete: '删除', done: '成交' }

	def status_name
	  status.blank? ? "" : ActivateAsset::STATUS["#{status}".to_sym]
	end

	def self.set_invalid
		ActivateAsset.where(status: "valid").each do |x|
			if x.created_at.to_date.eql?(Date.today-30.days)
				x.update status: "invalid"
				m = Message.create title: "你好，你于#{x.created_at.to_date}发布的资产盘活信息<#{x.name}>已过30天有效期，已失效。", activate_asset_id: x.id, is_release: false
				UserMessage.create message_id: m.id, user_id: x.create_user_id, is_read: false
			end
		end
	end

	
end
