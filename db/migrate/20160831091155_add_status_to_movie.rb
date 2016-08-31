class AddStatusToMovie < ActiveRecord::Migration[5.0]
  def change
    add_column :movies, :status, :string, default: "pending"
  end
end
