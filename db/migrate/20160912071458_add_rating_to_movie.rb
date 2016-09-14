class AddRatingToMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :rating, :float
  end
end
