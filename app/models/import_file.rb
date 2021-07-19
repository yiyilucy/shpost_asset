class ImportFile < ActiveRecord::Base
	belongs_to :activate_asset

	def self.upload_info(file, activate_asset)
    if !file.original_filename.empty?
      direct = "#{Rails.root}/upload/activate_asset/"
      if !File.exist?(direct)
        Dir.mkdir(direct)          
      end
      filename = "#{Time.now.to_f}_#{file.original_filename}"

      file_path = direct + filename
      File.open(file_path, "wb") do |f|
        f.write(file.read)
      end

      ImportFile.create! file_name: filename, file_path: file_path, activate_asset_id: activate_asset.id

      file_path
    end
  end

  
end
