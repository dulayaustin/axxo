class AddIndexOnMovieCategories < ActiveRecord::Migration[5.0]
  def change
    add_index :movie_categories, :category_id
    add_index :movie_categories, :movie_id
  end
end
