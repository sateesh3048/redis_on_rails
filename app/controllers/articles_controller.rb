class ArticlesController < ApplicationController

  def index
    @articles = Article.get_articles(params)
  end
end
