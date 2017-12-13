class Article < ApplicationRecord
  # Defining associations
  has_many :comments
  has_many :article_tags
  has_many :tags, through: :article_tags
  has_many :article_likers
  has_many :article_viewers
  belongs_to :user

  # Defining validations
  validates :title, presence: true, uniqueness: true

  # Defining attributes
  attribute :can_flush, :boolean, default: true

  #Defining callbacks
  after_save :flush_all_cached_articles
  after_destroy :flush_all_cached_articles

  def self.get_articles(params)
    case params[:article_type]
      when "most_viewed"
        article_ids = $redis.zrevrange "article_viewers_count", 0,30
        Article.find_articles_by_ids(article_ids)
      when "most_liked"
        article_ids = $redis.zrevrange "article_likes_count", 0,30
        Article.find_articles_by_ids(article_ids)
      when "most_commented"
        article_ids = $redis.zrevrange "article_comments_count", 0,30
        Article.find_articles_by_ids(article_ids)
      else
        Article.articles_list
      end
  end

 def self.find_articles_by_ids(article_ids)
  Article.find(article_ids)
 end

  def self.comments_count(article_id)
    comments_count = $redis.zscore "article_comments_count", article_id
    if comments_count.blank?
      comments_count = Comment.where(article_id: article_id).count
      $redis.zadd "article_comments_count", comments_count, article_id
    end
    comments_count.to_i
  end

  def self.likes_count(article_id)
    likes_count = $redis.zscore "article_likes_count", article_id
    if likes_count.blank?
      likes_count = ArticleLiker.where(article_id: article_id).count
      $redis.zadd "article_likes_count", likes_count, article_id
    end
    likes_count.to_i
  end

  def self.views_count(article_id)
    views_count = $redis.zscore "article_viewers_count", article_id
    if views_count.blank?
      views_count = ArticleViewer.where(article_id: article_id).count
      $redis.zadd "article_viewers_count", views_count, article_id
    end
    views_count.to_i
  end

  def self.tag_names(article_id)
    tag_names =  $redis.smembers "article_#{article_id}_tag_names"
    if tag_names.blank?
      tag_names = Tag.joins(:articles).where("articles.id" => article_id).pluck(:name)
      $redis.sadd "article_#{article_id}_tag_names", tag_names if tag_names.present?
    end
    tag_names.join(" ")
  end

  private
    def self.articles_list
      articles = $redis.get("articles")
      if articles.blank?
        articles = Article.all.to_json
        $redis.set("articles", articles)
      end
      JSON.load articles
    end

    def flush_all_cached_articles
      if self.can_flush?
        $redis.del("articles")
        Article.articles_list
      end
    end
end
