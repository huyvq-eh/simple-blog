class ChangePostsTable < ActiveRecord::Migration[6.1]
  def change
    change_table :posts do |t|
      t.remove :author
      t.index :title
      t.belongs_to :user, foreign_key: true
    end
  end

end
