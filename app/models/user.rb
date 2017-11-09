class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  belongs_to :unit
  has_many :user_logs
  has_many :roles, dependent: :destroy

  devise :database_authenticatable, #:registerable,
         :recoverable, :rememberable, :trackable, :validatable

  validates_presence_of :username, :name, :unit_id, :role, :message => '不能为空字符'#,

  validates_uniqueness_of :username, :message => '该用户已存在'

  ROLE = { superadmin: '超级管理员', unitadmin: '机构管理员', deviceadmin: '设备管理员', accountant: '财务', inventoryadmin: '盘点员' }

  def rolename
    User::ROLE[role.to_sym]
  end

  def superadmin?
    (role.eql? 'superadmin') ? true : false
  end

  def unitadmin?
    (role.eql? 'unitadmin') ? true : false
  end

  def user?
    (role.eql? 'user') ? true : false
  end

  def deviceadmin?
    (role.eql? 'deviceadmin') ? true : false
  end

  def accountant?
    (role.eql? 'accountant') ? true : false
  end

  def inventoryadmin?
    !roles.where(role: 'inventoryadmin').empty?
  end

  def email_required?
    false
  end

  def password_required?
    encrypted_password.blank? ? true : false
  end

end
