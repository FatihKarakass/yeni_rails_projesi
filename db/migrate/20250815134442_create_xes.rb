class CreateXes < ActiveRecord::Migration[8.0]
  def change
    create_table :xes do |t|
      t.belongs_to :user, null: false, foreign_key: true
      t.belongs_to :xaccount, null: false, foreign_key: true
      t.text :body
      t.datetime :publish_at
      t.string :tweet_id

      t.timestamps
    end
  end
end
