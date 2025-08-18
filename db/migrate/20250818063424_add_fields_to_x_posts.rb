class AddFieldsToXPosts < ActiveRecord::Migration[8.0]
  def change
    add_reference :x_posts, :x_account, null: false, foreign_key: true
    add_column :x_posts, :body, :text
    add_column :x_posts, :publish_at, :datetime
    add_column :x_posts, :x_post_id, :string
  end
end
