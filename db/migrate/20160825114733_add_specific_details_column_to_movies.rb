class AddSpecificDetailsColumnToMovies < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :image, :string
    add_column :movies, :torrent, :string
    add_column :movies, :plot, :text
    add_column :movies, :youtube_url, :string
  end
end
