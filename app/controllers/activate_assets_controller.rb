class ActivateAssetsController < ApplicationController
  load_and_authorize_resource

  def index
    @activate_assets = ActivateAsset.accessible_by(current_ability).where.not(status: "delete")
    @activate_assets_grid = initialize_grid(@activate_assets,
         :order => 'activate_assets.created_at',
         :order_direction => 'desc')
  end

  def show
  end

  def new
    # @activate_asset = ActivateAsset.new
  end

  def edit
  end

  def create
    # binding.pry
    if params[:import_file_id].blank?
      flash[:error] = "必须上传附件"
      redirect_to new_activate_asset_path
    else
      @activate_asset.create_unit_id = current_user.try :unit_id
      @activate_asset.create_user_id = current_user.id
      @activate_asset.import_file_id = params[:import_file_id].to_i
      @activate_asset.name = params[:name]
      @activate_asset.contact = params[:contact]
      @activate_asset.tel = params[:tel]
      @activate_asset.introduce = params[:introduce]

      respond_to do |format|
        if @activate_asset.save
          Message.create title: "你好，#{Time.now.strftime('%Y%m%d')}#{current_user.unit.blank? ? "" : current_user.unit.name}发布了一条新的资产盘活信息,详情请至信息公告查看并下载", activate_asset_id: @activate_asset.id
          
          format.html { redirect_to @activate_asset, notice: I18n.t('controller.create_success_notice', model: '资产盘活') }
          format.json { render action: 'show', status: :created, location: @activate_asset }
        else
          format.html { render action: 'new' }
          format.json { render json: @activate_asset.errors, status: :unprocessable_entity }
        end
      end
    end
  end

  def update
    respond_to do |format|
      if @activate_asset.update(activate_asset_params)
        Message.create title: "你好，#{Time.now.strftime('%Y%m%d')}#{current_user.unit.blank? ? "" : current_user.unit.name}修改了之前发布的资产盘活信息,详情请至'查看信息'查看并下载", activate_asset_id: @activate_asset.id
        format.html { redirect_to @activate_asset, notice: I18n.t('controller.update_success_notice', model: '资产盘活')  }
        format.json { head :no_content }
      else
        format.html { render action: 'edit' }
        format.json { render json: @activate_asset.errors, status: :unprocessable_entity }
      end
    end
  end

  def destroy
    @activate_asset.update status: "delete"
    
    respond_to do |format|
      format.html { redirect_to activate_assets_url }
      format.json { head :no_content }
    end
  end

  # def import
  #   flash_message = "上传成功！"

  #   unless request.get?
  #     @activate_asset = ActivateAsset.find(params[:id].to_i)
  #     if !@activate_asset.blank?
  #       if !((params[:file]['file'].original_filename.include?('.xlsx')) || (params[:file]['file'].original_filename.include?('.xls')) || (params[:file]['file'].original_filename.include?('.csv')))
  #         flash_message = "上传失败！请上传xlsx，xls或csv格式的文件!"
  #       else
  #         if !@activate_asset.import_file.blank?
  #           @activate_asset.import_file.delete
  #         end
  #         if !(file = ImportFile.upload_info(params[:file]['file'], @activate_asset))
  #           flash_message = "上传失败!"
  #         end
  #       end
  #     else
  #       flash_message = "上传失败!"
  #     end
  #     flash[:notice] = flash_message

  #     redirect_to activate_assets_url
  #   end
  # end

  

  def download
    file_path = nil

    file_path = @activate_asset.import_file.file_path if !@activate_asset.import_file.blank?
        
    if !file_path.blank? and File.exist?(file_path)
      io = File.open(file_path)
      filename = File.basename(file_path)
      send_data(io.read, :type => "text/excel;charset=utf-8; header=present",              :filename => filename)
      io.close
    else
      redirect_to activate_assets_url, :notice => '文件不存在，下载失败！'
    end
  end

  def done
    @activate_asset.update status: "done"

    redirect_to activate_assets_url, :notice => '信息状态已更改为成交！'
  end


  private
    def set_activate_asset
      @activate_asset = ActivateAsset.find(params[:id])
    end

    def activate_asset_params
      params.permit(:name, :contact, :tel, :introduce)
    end
end
