class CreateArticleTags < ActiveRecord::Migration[5.1]
  def change
    create_table :article_tags do |t|
      t.string :article_id
      t.string :tag_id

      t.timestamps
    end
  end
end
