class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :unit

  validates_presence_of :user_id, :unit_id, :role, :message => '不能为空字符'
  validates_uniqueness_of :user_id, scope: [:unit_id, :role], :message => '该角色在该仓库中角色已存在'
  
  ROLE1 = { unitadmin: '机构管理员', deviceadmin: '设备管理员', accountant: '财务', inventoryadmin: '盘点员', sgsadmin: '市公司管理员'}
  ROLE2 = { unitadmin: '机构管理员', deviceadmin: '设备管理员', accountant: '财务', inventoryadmin: '盘点员'}

  def self.get_units_by_user_id(user_id)
    Role.where("user_id = ?", user_id).group(:unit_id)
  end
end
