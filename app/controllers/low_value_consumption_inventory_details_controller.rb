class LowValueConsumptionInventoryDetailsController < ApplicationController
  before_action :set_low_value_consumption_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @low_value_consumption_inventory_details = LowValueConsumptionInventoryDetail.all
    respond_with(@low_value_consumption_inventory_details)
  end

  def show
    respond_with(@low_value_consumption_inventory_detail)
  end

  def new
    @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.new
    respond_with(@low_value_consumption_inventory_detail)
  end

  def edit
  end

  def create
    @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.new(low_value_consumption_inventory_detail_params)
    @low_value_consumption_inventory_detail.save
    respond_with(@low_value_consumption_inventory_detail)
  end

  def update
    @low_value_consumption_inventory_detail.update(low_value_consumption_inventory_detail_params)
    respond_with(@low_value_consumption_inventory_detail)
  end

  def destroy
    @low_value_consumption_inventory_detail.destroy
    respond_with(@low_value_consumption_inventory_detail)
  end

  def recheck
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    @low_value_consumption_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      if !@low_value_consumption_inventory_detail.blank?
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory 
        @low_value_consumption_inventory_unit = @low_value_consumption_inventory_detail.low_value_consumption_inventory_unit

        LowValueConsumptionInventoryDetail.recheck(@low_value_consumption_inventory_detail, @low_value_consumption_inventory, @low_value_consumption_inventory_unit)

        respond_to do |format|
          format.html { redirect_to low_value_consumption_inventory_low_value_consumption_inventory_details_path(@low_value_consumption_inventory) }
          format.json { head :no_content }
        end
      end
    end
  end

  def scan
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory if !@low_value_consumption_inventory_detail.blank?
    end
  end

  def match
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory if !@low_value_consumption_inventory_detail.blank?
      @low_value_consumption_inventory_detail.update inventory_status: "match", inventory_user_id: current_user.id, end_date: Time.now

    end
    respond_to do |format|
      format.html { redirect_to scan_low_value_consumption_inventory_detail_path(@low_value_consumption_inventory_detail) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    if !params.blank? and !params[:id].blank?
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
      if !@low_value_consumption_inventory_detail.blank?
        @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory 
        # binding.pry
        @low_value_consumption_inventory_detail.update inventory_status: "unmatch", desc: (params[:desc_content].blank? ? "" : params[:desc_content]), inventory_user_id: current_user.id, end_date: Time.now
      end
    end
    respond_to do |format|
      format.html { redirect_to scan_low_value_consumption_inventory_detail_path(@low_value_consumption_inventory_detail) }
      format.json { head :no_content }
    end
  end

  def import
    @low_value_consumption_inventory_detail = nil
    @low_value_consumption_inventory = nil
    @fname = nil

    unless request.get?
      if !params.blank? and !params[:id].blank?
        @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id].to_i)
        if !@low_value_consumption_inventory_detail.blank?
          @low_value_consumption_inventory = @low_value_consumption_inventory_detail.low_value_consumption_inventory 
                    
          if img_file = low_value_consumpriton_info_img_upload_path(params[:file], @low_value_consumption_inventory_detail)
            flash[:notice] = "上传成功!!"
            if img_file.blank?
              flash[:error] = "上传失败！!"
            else
              if LvcImg.find_by(lvc_inventory_detail_id: params[:id]).blank?
                LvcImg.create(lvc_inventory_detail_id: params[:id], low_value_consumption_info_id: @low_value_consumption_inventory_detail.low_value_consumption_info_id, img_url: ("/" + img_file.split(/\/public\//).last))
              else
                LvcImg.find_by(lvc_inventory_detail_id: params[:id]).update img_url: ("/" + img_file.split(/\/public\//).last)
              end
            end
          end
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to scan_low_value_consumption_inventory_detail_path(@low_value_consumption_inventory_detail) }
      format.json { head :no_content }
    end           
  end

  def low_value_consumpriton_info_img_upload_path(file, inventory_detail)
    fname = Digest::MD5.hexdigest(inventory_detail.asset_name + "_" + inventory_detail.asset_no) + ".jpg"
    direct = "#{Rails.root}/public/shpost_asset/low_value_consumption_info/"
    @filename = "#{Time.now.to_f}_#{fname}"
    file_path = direct + @filename
    # binding.pry 
    File.open(file_path, "wb") do |f|
      f.write(file.read)
    end
    image = MiniMagick::Image.open(file_path) 
    image.quality I18n.t("image_util_param.image_quality")
    image.write(file_path)
    # end
    file_path
    
  end

  

  private
    def set_low_value_consumption_inventory_detail
      @low_value_consumption_inventory_detail = LowValueConsumptionInventoryDetail.find(params[:id])
    end

    def low_value_consumption_inventory_detail_params
      params[:low_value_consumption_inventory_detail]
    end
end
