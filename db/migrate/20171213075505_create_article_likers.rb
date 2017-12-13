class CreateArticleLikers < ActiveRecord::Migration[5.1]
  def change
    create_table :article_likers do |t|
      t.references :article, foreign_key: true
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
