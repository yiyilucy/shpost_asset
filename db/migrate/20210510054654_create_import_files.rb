class CreateImportFiles < ActiveRecord::Migration
  def change
    create_table :import_files do |t|
    	t.string :file_name, null: false
      t.string :file_path, null: false, default: ''
      
      t.timestamps
    end
  end
end
