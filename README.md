Note: This project is created for learning redis usage.

Redis configuration :-
======================

Created redis.rb file inside config/initializers/redis.rb

  $redis = Redis::Namespace.new("rails_app", :redis => Redis.new)

Update cache store in config/environments/developement(or)/prodcution.rb
===============================================

    config.action_controller.perform_caching = true
    config.cache_store = :redis_store, "redis://localhost:6379/0/cache", {expires_in: 90.minutes } 


Redis String :-
==============

I have used redis to cache all the articles once fetched from db.

Eg: 

    def self.articles_list
      articles = $redis.get("articles")
      if articles.blank?
        articles = Article.all.to_json
        $redis.set("articles", articles)
      end
      JSON.load articles
    end

Redis Sets :-
=============

I have used redis sets to store all the tags related
to articles.

Eg:-

    def add_tag_to_article
      $redis.sadd "article_#{article_id}_tag_names", self.tag.try(:name)
    end

    def remove_tag_from_article
      $redis.srem "article_#{article_id}_tag_names", self.tag.try(:name)
    end

Redis Sorted Sets :
=================== 

I have used sorted sets to store article likes count,
article comments count, article viewers count.
So that I can sort articles based on most viewed articles, most liked articles, most commented articles.

Eg: 

    def increase_comments_count
      $redis.zincrby "article_comments_count", 1, self.article_id
    end

    def decrease_comments_count
      $redis.zincrby "article_comments_count", -1, self.article_id
    end

    def update_article_viewers_count
      $redis.zincrby "article_viewers_count", 1, self.article_id
    end

    def update_article_likers_count
      $redis.zincrby "article_likes_count", 1, self.article_id
    end


Listing Articles Based on Likes Count, Views Count ..
======================================================

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

Performance monitoring :-
=========================

We can observe performance changes using 
below gems.


gem 'rack-mini-profiler'
gem 'flamegraph'
gem 'stackprof' 
gem 'memory_profiler'



