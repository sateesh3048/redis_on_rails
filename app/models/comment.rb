class Comment < ApplicationRecord
  # Defininig associations
  belongs_to :user
  belongs_to :article
  after_create :increase_comments_count
  after_destroy :decrease_comments_count

  private
    def increase_comments_count
      $redis.zincrby "article_comments_count", 1, self.article_id
    end

    def decrease_comments_count
      $redis.zincrby "article_comments_count", -1, self.article_id
    end
end
