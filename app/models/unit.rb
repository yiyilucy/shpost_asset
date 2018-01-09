class Unit < ActiveRecord::Base
  has_many :users, dependent: :destroy
  # has_many :units, as: :parent
  # belongs_to :unit
  belongs_to :parent, :class_name => 'Unit'
  has_many :children, :class_name => 'Unit',:foreign_key => 'parent_id',:dependent => :destroy
  has_many :fixed_asset_infos, dependent: :destroy
  
  validates_presence_of :name, :message => '不能为空'
  validates_uniqueness_of :name, :message => '该单位已存在'

  # validates_uniqueness_of :short_name, :message => '该缩写已存在'

  UNIT_LEVEL = {1=>'1',2=>'2',3=>'3',4=>'4'}

  def can_delete?
    if self.children.blank? && self.users.blank?
      return true
    else
      return false
    end
  end

  def is_facility_management_unit_name
     if is_facility_management_unit
        name = "是"
     else
        name = "否"
     end
   end

end
