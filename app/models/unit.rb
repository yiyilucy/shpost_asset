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

  def print_unit_name
    self.unit_desc.blank? ? self.name : self.unit_desc
  end

  def self.get_relevant_unit_name(relevant_unit_id)
    relename = Unit.find_by(id: relevant_unit_id).try(:name)
  end

  def self.get_use_unit_name(use_unit_id)
    usename = Unit.find_by(id: use_unit_id).try(:name)
  end
    
end
