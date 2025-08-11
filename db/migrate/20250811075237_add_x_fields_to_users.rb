class AddXFieldsToUsers < ActiveRecord::Migration[8.0]
  def change
    add_column :users, :x_id, :string
    add_column :users, :x_username, :string
    add_column :users, :x_name, :string
    add_column :users, :x_profile_image_url, :string
  end
end
