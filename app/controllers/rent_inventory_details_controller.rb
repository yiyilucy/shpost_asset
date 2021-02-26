class RentInventoryDetailsController < ApplicationController
  before_action :set_rent_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @rent_inventory_details = RentInventoryDetail.all
    respond_with(@rent_inventory_details)
  end

  def show
    respond_with(@rent_inventory_detail)
  end

  def new
    @rent_inventory_detail = RentInventoryDetail.new
    respond_with(@rent_inventory_detail)
  end

  def edit
  end

  def create
    @rent_inventory_detail = RentInventoryDetail.new(rent_inventory_detail_params)
    @rent_inventory_detail.save
    respond_with(@rent_inventory_detail)
  end

  def update
    @rent_inventory_detail.update(rent_inventory_detail_params)
    respond_with(@rent_inventory_detail)
  end

  def destroy
    @rent_inventory_detail.destroy
    respond_with(@rent_inventory_detail)
  end

  def recheck
    @rent_inventory_detail = nil
    @rent_inventory = nil
    @rent_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      if !@rent_inventory_detail.blank?
        @rent_inventory = @rent_inventory_detail.rent_inventory 
        @rent_inventory_unit = @rent_inventory_detail.rent_inventory_unit

        LowValueConsumptionInventoryDetail.recheck(@rent_inventory_detail, @rent_inventory, @rent_inventory_unit)

        respond_to do |format|
          format.html { redirect_to rent_inventory_rent_inventory_details_path(@rent_inventory) }
          format.json { head :no_content }
        end
      end
    end
  end

  def scan
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      @rent_inventory = @rent_inventory_detail.rent_inventory if !@rent_inventory_detail.blank?
    end
  end

  def match
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      @rent_inventory = @rent_inventory_detail.rent_inventory if !@rent_inventory_detail.blank?
      @rent_inventory_detail.update inventory_status: "match", inventory_user_id: current_user.id, end_date: Time.now

    end
    respond_to do |format|
      format.html { redirect_to scan_rent_inventory_detail_path(@rent_inventory_detail) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @rent_inventory_detail = nil
    @rent_inventory = nil
    if !params.blank? and !params[:id].blank?
      @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
      if !@rent_inventory_detail.blank?
        @rent_inventory = @rent_inventory_detail.rent_inventory 
        @rent_inventory_detail.update inventory_status: "unmatch", desc: (params[:desc_content].blank? ? "" : params[:desc_content]), inventory_user_id: current_user.id, end_date: Time.now
      end
    end
    respond_to do |format|
      format.html { redirect_to scan_rent_inventory_detail_path(@rent_inventory_detail) }
      format.json { head :no_content }
    end
  end

  def import
    @rent_inventory_detail = nil
    @rent_inventory = nil
    @fname = nil

    unless request.get?
      if !params.blank? and !params[:id].blank?
        @rent_inventory_detail = RentInventoryDetail.find(params[:id].to_i)
        if !@rent_inventory_detail.blank?
          @rent_inventory = @rent_inventory_detail.rent_inventory 
                    
          if img_file = rent_info_img_upload_path(params[:file], @rent_inventory_detail)
            flash[:notice] = "上传成功!!"
            if img_file.blank?
              flash[:error] = "上传失败！!"
            else
              if RentImg.find_by(rent_inventory_detail_id: params[:id]).blank?
                RentImg.create(rent_inventory_detail_id: params[:id], rent_info_id: @rent_inventory_detail.rent_info_id, img_url: ("/" + img_file.split(/\/public\//).last))
              else
                RentImg.find_by(rent_inventory_detail_id: params[:id]).update img_url: ("/" + img_file.split(/\/public\//).last)
              end
            end
          end
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to scan_rent_inventory_detail_path(@rent_inventory_detail) }
      format.json { head :no_content }
    end           
  end
  def rent_info_img_upload_path(file, inventory_detail)
    fname = Digest::MD5.hexdigest(inventory_detail.asset_name + "_" + inventory_detail.asset_no) + ".jpg"
    direct = "#{Rails.root}/public/shpost_asset/rent_info/"
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
    def set_rent_inventory_detail
      @rent_inventory_detail = RentInventoryDetail.find(params[:id])
    end

    def rent_inventory_detail_params
      params[:rent_inventory_detail]
    end
end
