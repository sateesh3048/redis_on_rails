# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rails db:seed command (or created alongside the database with db:setup).
#
# Examples:
#
#   movies = Movie.create([{ name: 'Star Wars' }, { name: 'Lord of the Rings' }])
#   Character.create(name: 'Luke', movie: movies.first)

if Tag.count < 100
  100.times do 
    Tag.find_or_create_by(name: Faker::Lorem.word)
  end
end

1000.times do 
  User.create(name: Faker::Name.name, email: Faker::Internet.unique.email, age: (25..75).to_a.sample)
end

user_ids = User.pluck(:id)
500.times do 
  Article.create(title: Faker::Lorem.unique.sentence , content: Faker::Lorem.paragraph, published_date: Faker::Date.between(90.days.ago, Date.today), user_id: user_ids.sample, can_flush: false)
end

article_ids = Article.pluck(:id)
4000.times do 
  Comment.create(description: Faker::Lorem.unique.sentence, posted_date: Faker::Date.between(30.days.ago, Date.today), user_id: user_ids.sample, article_id: article_ids.sample)
end

tag_ids = Tag.pluck(:id).uniq
Article.find_each do |article|
  article.tag_ids = tag_ids.sample(rand(0..20)).uniq
end

Article.find_each do |article|
  viewer_ids = user_ids.sample(rand(0..500)).uniq
  viewer_ids.each do |viewer_id|
    ArticleViewer.create article_id: article.id, user_id: viewer_id
  end
end

Article.find_each do |article|
  liker_ids = user_ids.sample(rand(0..500)).uniq
  liker_ids.each do |viewer_id|
    ArticleLiker.create article_id: article.id, user_id: viewer_id
  end
end

