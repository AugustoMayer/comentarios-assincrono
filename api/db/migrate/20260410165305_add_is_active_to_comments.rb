class AddIsActiveToComments < ActiveRecord::Migration[8.1]
  def change
    add_column :comments, :is_active, :boolean, default: true
  end
end
