class ArticleTag < ApplicationRecord
  belongs_to :article
  belongs_to :tag  

  # Defining callbacks
  after_create :add_tag_to_article
  after_destroy :remove_tag_from_article

  private

  def add_tag_to_article
    $redis.sadd "article_#{article_id}_tag_names", self.tag.try(:name)
  end

  def remove_tag_from_article
    $redis.srem "article_#{article_id}_tag_names", self.tag.try(:name)
 end
end
