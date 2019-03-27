class UsersController < ApplicationController
  load_and_authorize_resource :user

  user_logs_filter only: [:create, :destroy], symbol: :username#, object: :user, operation: '新增用户'

  # GET /users
  # GET /users.json
  def index
    if current_user.unit.blank? or [0, 1].include?current_user.unit.unit_level
      @users = User.all.order("users.unit_id, users.name")
    else
      lv3units = Unit.where(parent_id: current_user.unit_id).select(:id)
      units = Unit.where("parent_id = ? or id = ? or parent_id in (?)", current_user.unit_id, current_user.unit_id, lv3units).select(:id)
      @users = User.where(unit_id: units).order("users.unit_id, users.name")
    end
    @users_grid = initialize_grid(@users)
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    #@user = User.new
  end

  # GET /users/1/edit
  def edit
  end

  # POST /users
  # POST /users.json
  def create
    # binding.pry
    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: I18n.t('controller.create_success_notice', model: '用户') }
        format.json { render action: 'show', status: :created, location: @user }
      else
        format.html { render action: 'new' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end     
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html { redirect_to @user, notice: I18n.t('controller.update_success_notice', model: '用户') }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url }
      format.json { head :no_content }
    end
  end

  def import
    unless request.get?
      if file = upload_user(params[:file]['file'])       
        ActiveRecord::Base.transaction do
          begin
            sheet_error = []
            rowarr = [] 
            instance=nil
            flash_message = "导入成功!"
            a = 0
            
            if file.include?('.xlsx')
              instance= Roo::Excelx.new(file)
            elsif file.include?('.xls')
              instance= Roo::Excel.new(file)
            elsif file.include?('.csv')
              instance= Roo::CSV.new(file)
            end
            instance.default_sheet = instance.sheets.first
            
            2.upto(instance.last_row) do |line|
              a = line
# binding.pry
              rowarr = instance.row(line)
              unit_index = to_string(rowarr[0]).strip
              role_index = to_string(rowarr[1]).strip
              name_index = to_string(rowarr[2]).strip
              username_index = to_string(rowarr[3]).strip.downcase
              # password_index = to_string(rowarr[4]).strip
              password_index = username_index + "12345"

              unit = Unit.where("unit_level = ? and name like ?", 2, "%#{unit_index}%").first

              if unit.blank?
                flash_message = unit_index + ",该单位不存在!"
                break
              else
                if User.find_by(username: username_index).blank?
                  user = User.create(username: username_index, name: name_index, password: password_index, email: username_index + "@qq.com", unit_id: unit.id)
                  if role_index.eql?"二级单位设备管理员"
                    user.update role: "deviceadmin"
                    Role.create(user_id: user.id, unit_id: unit.id, role: "deviceadmin")
                  elsif role_index.eql?"二级单位财务"
                    user.update role: "unitadmin"
                    Role.create(user_id: user.id, unit_id: unit.id, role: "unitadmin")
                    Role.create(user_id: user.id, unit_id: unit.id, role: "accountant")
                  end
                else
                  user = User.find_by(username: username_index)
                  if role_index.eql?"二级单位设备管理员"
                    Role.create(user_id: user.id, unit_id: unit.id, role: "deviceadmin") if Role.find_by(user_id: user.id, unit_id: unit.id, role: "deviceadmin").blank?
                  elsif role_index.eql?"二级单位财务"
                    Role.create(user_id: user.id, unit_id: unit.id, role: "unitadmin") if Role.find_by(user_id: user.id, unit_id: unit.id, role: "unitadmin").blank?
                    Role.create(user_id: user.id, unit_id: unit.id, role: "accountant") if Role.find_by(user_id: user.id, unit_id: unit.id, role: "accountant").blank?
                  end
                end
              end
            end

            flash[:notice] = flash_message

            redirect_to :action => 'index'

            rescue Exception => e
            flash[:alert] = e.message + "第" + a.to_s + "行"
            raise ActiveRecord::Rollback
          end
        end
      end
    end
  end

  def to_string(text)
    if text.is_a? Float
      return text.to_s.split('.0')[0]
    else
      return text
    end
  end

  def select_roles
    if !params[:unit_id].blank?
      unit = Unit.find(params[:unit_id].to_i)
      if unit.unit_level == 1
        @roles = Role::ROLE1.invert
      elsif unit.unit_level == 2
        @roles = Role::ROLE2.invert
      elsif unit.unit_level == 3 || unit.unit_level == 4
        @roles = Role::ROLE34.invert
      end    
      
      respond_to do |format|
        format.js 
      end
    end
  end


  private
    # Use callbacks to share common setup or constraints between actions.
    # def set_user
    #   @user = User.find(params[:id])
    # end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params[:user].permit(:username, :name, :password, :unit_id, :email, :role)
    end

    def upload_user(file)
      if !file.original_filename.empty?
        direct = "#{Rails.root}/upload/user/"
        filename = "#{Time.now.to_f}_#{file.original_filename}"

        file_path = direct + filename
        File.open(file_path, "wb") do |f|
           f.write(file.read)
        end
        file_path
      end
    end
end
