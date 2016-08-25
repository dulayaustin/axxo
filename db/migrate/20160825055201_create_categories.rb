class CreateCategories < ActiveRecord::Migration[5.0]
  def change
    create_table :categories do |t|
      t.string :name
      t.timestamps
    end
    ["horror", "drama", "action", "sports", "adventure", "animation", "biography", "thriller", "comedy", "crime", "documentary", "war", "family", "fantasy", "music", "western", "mystery", "romance", "sci-fi"].each do |cat|
      Category.find_or_create_by(name: cat.downcase)
    end
  end



  

end
