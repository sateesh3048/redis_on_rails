class ArticleViewer < ApplicationRecord
  belongs_to :user
  belongs_to :article

  after_create :update_article_viewers_count
  def update_article_viewers_count
    $redis.zincrby "article_viewers_count", 1, self.article_id
  end
end
