class UserLog < ActiveRecord::Asset
  belongs_to :user
  belongs_to :parent, polymorphic: true  

  validates_presence_of :user_id, :operation
end
