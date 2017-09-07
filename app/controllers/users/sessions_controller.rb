class Users::SessionsController < Devise::SessionsController
  def create
  	puts "Users::SessionsController start"
    super do |resource|
      puts "test Users::SessionsController"
      # binding.pry
      # if current_user.username.eql?"unit1admin"
      #   session[:current_storage] = nil
      # else
      
      @user_log = UserLog.create(user: current_user, operation: '用户登录')
      # end
    end
    puts "Users::SessionsController end"
  end

  def destroy
  	@user_log = UserLog.create(user: current_user, operation: '用户退出')
  	super do |resource|
  		session[:current_storage] = nil
  	end
  end
end