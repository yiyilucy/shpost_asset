class Ability
  include CanCan::Ability

  def initialize(user = nil)
    user ||= User.new
    if user.superadmin?
        can :manage, User
        can :manage, Unit
        can :manage, UserLog
        can :manage, Role
        can :role, :unitadmin
        can :role, :deviceadmin
        can :role, :accountant
        can :role, :inventoryadmin
        can :role, :sgsadmin

        # cannot :role, :superadmin
        cannot [:role, :create, :destroy, :update], User, role: 'superadmin'
        can :update, User, id: user.id

        # can :manage, FixedAssetCatalog
        # can :manage, LowValueConsumptionCatalog
        # can :read, FixedAssetInfo
        # can :read, LowValueConsumptionInfo
        # can [:new, :read], Purchase
        can :manage, Sequence
        # can :manage, FixedAssetInventory
        # can :manage, FixedAssetInventoryDetail
    end

    if user.sgsadmin?
        can :manage, User
        can :manage, Unit
        can :manage, UserLog
        can :manage, Role
        can :role, :unitadmin
        can :role, :deviceadmin
        can :role, :accountant
        can :role, :inventoryadmin

        # cannot :role, :superadmin
        cannot [:role, :create, :destroy, :update], User, role: 'superadmin'
        can :update, User, id: user.id

        can :manage, FixedAssetCatalog
        can :manage, LowValueConsumptionCatalog
        can [:read, :print], FixedAssetInfo
        can [:read, :discard_index, :print], LowValueConsumptionInfo
        # can [:new, :read], Purchase
        can :manage, Sequence
        can :manage, FixedAssetInventory
        cannot :doing_index, FixedAssetInventory
        can :manage, FixedAssetInventoryDetail
        can :manage, LowValueConsumptionInventory
        cannot :doing_index, LowValueConsumptionInventory
        can :manage, LowValueConsumptionInventoryDetail
    end
        
    if user.unitadmin?
    #can :manage, :all

        can :manage, Unit

        can :manage, User

        can :manage, Role
        cannot :role, User, role: 'superadmin'
        cannot :role, User, role: 'sgsadmin'
        can :role, :unitadmin
        can :role, :deviceadmin
        can :role, :accountant
        can :role, :inventoryadmin
        
        # cannot :role, User, role: 'unitadmin'
        # cannot [:create, :destroy, :update], User, role: ['unitadmin', 'superadmin']
        can :update, User, id: user.id
    end    

    if user.deviceadmin?
        can :read, FixedAssetCatalog
        can :read, LowValueConsumptionCatalog
        can :manage, FixedAssetInfo
        can :manage, LowValueConsumptionInfo
        can :manage, Purchase
        cannot [:approve, :decline], Purchase
        can :manage, Unit
        can :read, LvcDiscard
        can :read, LvcDiscardDetail
        can :manage, FixedAssetInventory
        can :manage, FixedAssetInventoryDetail
        can :manage, LowValueConsumptionInventory
        can :manage, LowValueConsumptionInventoryDetail
    end

    if user.accountant?
        can :read, FixedAssetCatalog
        can :read, LowValueConsumptionCatalog
        can :read, FixedAssetInfo, unit_id: user.unit_id
        can [:read, :discard_index], LowValueConsumptionInfo
        can [:to_do_index, :doing_index, :done_index, :read, :approve, :decline], Purchase
        can :manage, LvcDiscard
        can :manage, LvcDiscardDetail
        
    end
    
    if user.inventoryadmin?
        can [:read, :doing_index], FixedAssetInventory
        can :manage, FixedAssetInventoryDetail
        can :to_scan, FixedAssetInfo
        can [:read, :doing_index], LowValueConsumptionInventory
        can :manage, LowValueConsumptionInventoryDetail
        can :to_scan, LowValueConsumptionInfo
    end


  end
end




# if user.admin?(storage)


# Define abilities for the passed in user here. For example:
#
#   user ||= User.new # guest user (not logged in)
#   if user.admin?
#     can :manage, :all
#   else
#     can :read, :all
#   end
#
# The first argument to `can` is the action you are giving the user 
# permission to do.
# If you pass :manage it will apply to every action. Other common actions
# here are :read, :create, :update and :destroy.
#
# The second argument is the resource the user can perform the action on. 
# If you pass :all it will apply to every resource. Otherwise pass a Ruby
# class of the resource.
#
# The third argument is an optional hash of conditions to further filter the
# objects.
# For example, here the user can only update published articles.
#
#   can :update, Article, :published => true
#
# See the wiki for details:
# https://github.com/ryanb/cancan/wiki/Defining-Abilities
