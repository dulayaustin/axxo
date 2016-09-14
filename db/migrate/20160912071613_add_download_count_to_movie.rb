class AddDownloadCountToMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :download_count, :integer, default: 0
  end
end
