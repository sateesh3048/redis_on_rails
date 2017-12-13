class ArticleLiker < ApplicationRecord
  belongs_to :user
  belongs_to :article

  after_create :update_article_likers_count

  def update_article_likers_count
    $redis.zincrby "article_likes_count", 1, self.article_id
  end
end
