class Role < ActiveRecord::Base
  belongs_to :user
  belongs_to :unit

  validates_presence_of :user_id, :unit_id, :role, :message => '不能为空字符'
  validates_uniqueness_of :user_id, scope: [:unit_id, :role], :message => '该角色在该仓库中角色已存在'

  
  ROLE = { deviceadmin: '设备管理员', inventoryadmin: '盘点员', accountant: '财务', sgsadmin: '市公司管理员', unitadmin: '机构管理员', user: '普通用户'}

  ROLE1 = { user: '普通用户', unitadmin: '机构管理员', sgsadmin: '市公司管理员'}
  ROLE2 = { user: '普通用户', unitadmin: '机构管理员'}
  ROLE34 = { user: '普通用户'}

  ROLE1_JG = { deviceadmin: '设备管理员', inventoryadmin: '盘点员', accountant: '财务', sgsadmin: '市公司管理员'}
  ROLE1_SB = { deviceadmin: '设备管理员', inventoryadmin: '盘点员', sgsadmin: '市公司管理员'}
  ROLE1_CW = { accountant: '财务', inventoryadmin: '盘点员', sgsadmin: '市公司管理员'}

  ROLE2_JG = { deviceadmin: '设备管理员', inventoryadmin: '盘点员', accountant: '财务'}
  ROLE23_SB = { deviceadmin: '设备管理员', inventoryadmin: '盘点员'}
  ROLE2_CW = { accountant: '财务', inventoryadmin: '盘点员'}

  ROLE4_PD = { inventoryadmin: '盘点员'}

  def self.get_units_by_user_id(user_id)
    Role.where("user_id = ?", user_id).group(:unit_id)
  end
end
