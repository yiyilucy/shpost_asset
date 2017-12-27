class FixedAssetInventoryDetailsController < ApplicationController
  before_action :set_fixed_asset_inventory_detail, only: [:show, :edit, :update, :destroy]

  def index
    @fixed_asset_inventory_details = FixedAssetInventoryDetail.all
    respond_with(@fixed_asset_inventory_details)
  end

  def show
    respond_with(@fixed_asset_inventory_detail)
  end

  def new
    @fixed_asset_inventory_detail = FixedAssetInventoryDetail.new
    respond_with(@fixed_asset_inventory_detail)
  end

  def edit
  end

  def create
    @fixed_asset_inventory_detail = FixedAssetInventoryDetail.new(fixed_asset_inventory_detail_params)
    @fixed_asset_inventory_detail.save
    respond_with(@fixed_asset_inventory_detail)
  end

  def update
    @fixed_asset_inventory_detail.update(fixed_asset_inventory_detail_params)
    respond_with(@fixed_asset_inventory_detail)
  end

  def destroy
    @fixed_asset_inventory_detail.destroy
    respond_with(@fixed_asset_inventory_detail)
  end

  def recheck
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    @fixed_asset_inventory_unit = nil

    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      if !@fixed_asset_inventory_detail.blank?
        @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory 
        # @fixed_asset_inventory_unit = FixedAssetInventoryUnit.find_by(unit_id: @fixed_asset_inventory_detail.unit_id) if !@fixed_asset_inventory_detail.unit_id.blank?
        @fixed_asset_inventory_unit = @fixed_asset_inventory_detail.fixed_asset_inventory_unit

        @fixed_asset_inventory_detail.update inventory_status: "waiting", is_check: true
        @fixed_asset_inventory.update status: "doing"
        @fixed_asset_inventory_unit.update status: "unfinished" if !@fixed_asset_inventory_unit.blank?

        respond_to do |format|
          format.html { redirect_to fixed_asset_inventory_fixed_asset_inventory_details_path(@fixed_asset_inventory) }
          format.json { head :no_content }
        end
      end
    end
    
    
  end

  def scan
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory if !@fixed_asset_inventory_detail.blank?
    end
  end

  def match
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory if !@fixed_asset_inventory_detail.blank?
      @fixed_asset_inventory_detail.update inventory_status: "match"

    end
    respond_to do |format|
      format.html { redirect_to to_scan_fixed_asset_info_path(@fixed_asset_inventory_detail.fixed_asset_info) }
      format.json { head :no_content }
    end
  end

  def unmatch
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    if !params.blank? and !params[:id].blank?
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
      if !@fixed_asset_inventory_detail.blank?
        @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory 
        # binding.pry
        @fixed_asset_inventory_detail.update inventory_status: "unmatch", desc: params[:desc_content].blank? ? "" : params[:desc_content]
      end
    end
    respond_to do |format|
      format.html { redirect_to to_scan_fixed_asset_info_path(@fixed_asset_inventory_detail.fixed_asset_info) }
      format.json { head :no_content }
    end
  end

  def import
    @fixed_asset_inventory_detail = nil
    @fixed_asset_inventory = nil
    
    unless request.get?
      if !params.blank? and !params[:id].blank?
        @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id].to_i)
        if !@fixed_asset_inventory_detail.blank?
          @fixed_asset_inventory = @fixed_asset_inventory_detail.fixed_asset_inventory 
                    
          if img_file = fixed_asset_info_img_upload_path(params[:file], @fixed_asset_inventory_detail)
            flash[:notice] = "上传成功!!"
            if img_file.blank?
              flash[:error] = "上传失败！!"
            else
              if FixedAssetImg.find_by(fa_inventory_detail_id: params[:id]).blank?
                FixedAssetImg.create(fa_inventory_detail_id: params[:id], fixed_asset_info_id: @fixed_asset_inventory_detail.fixed_asset_info_id, img_url: ("/" + img_file.split(/\/public\//).last))
              else
                FixedAssetImg.find_by(fa_inventory_detail_id: params[:id]).update img_url: ("/" + img_file.split(/\/public\//).last)
              end
            end
          end
        end
      end
    end

    respond_to do |format|
      format.html { redirect_to scan_fixed_asset_inventory_detail_path(@fixed_asset_inventory_detail) }
      format.json { head :no_content }
    end           
  end

  def fixed_asset_info_img_upload_path(file, inventory_detail)
    fname = Digest::MD5.hexdigest(inventory_detail.asset_name + "_" + inventory_detail.asset_no) + ".jpg"
    direct = "#{Rails.root}/public/shpost_asset/fixed_asset_info/"
    @filename = "#{Time.now.to_f}_#{fname}"
    file_path = direct + @filename
    # binding.pry 
    File.open(file_path, "wb") do |f|
      f.write(file.read)
    end
    file_path
    
  end

  private
    def set_fixed_asset_inventory_detail
      @fixed_asset_inventory_detail = FixedAssetInventoryDetail.find(params[:id])
    end

    def fixed_asset_inventory_detail_params
      params[:fixed_asset_inventory_detail]
    end
end
