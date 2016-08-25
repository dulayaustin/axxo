class CreateDescriptions < ActiveRecord::Migration[5.0]
  def change
    create_table :descriptions do |t|
      t.references :movie, index: true
      t.string :imdb
      t.string :size
      t.string :quality
      t.string :language

      t.timestamps
    end
  end
end
