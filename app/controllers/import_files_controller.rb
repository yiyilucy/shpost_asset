class ImportFilesController < ApplicationController
  load_and_authorize_resource

  def index
    @import_files = ImportFile.all
    respond_with(@import_files)
  end

  def show
    respond_with(@import_file)
  end

  def new
    @import_file = ImportFile.new
    respond_with(@import_file)
  end

  def edit
  end

  def create
    @import_file = ImportFile.new(import_file_params)
    @import_file.save
    respond_with(@import_file)
  end

  def update
    @import_file.update(import_file_params)
    respond_with(@import_file)
  end

  def destroy
    @import_file.destroy
    respond_with(@import_file)
  end

  def import
    flash_message = "上传成功！"
    @fid = nil
    
    if !((params[:file]['file'].original_filename.include?('.xlsx')) || (params[:file]['file'].original_filename.include?('.xls')) || (params[:file]['file'].original_filename.include?('.csv')))
      flash_message = "上传失败！请上传xlsx，xls或csv格式的文件!"
    else
      if !(@fid = ImportFile.upload_info(params[:file]['file']))
        flash_message = "上传失败!"
      end
    end
    
    flash[:notice] = flash_message

    
    redirect_to new_activate_asset_path(fid: @fid, name: params[:name], contact: params[:contact], tel: params[:tel], introduce: params[:introduce])
    
  end

  
  private
    def set_import_file
      @import_file = ImportFile.find(params[:id])
    end

    def import_file_params
      params[:import_file]
    end
end
