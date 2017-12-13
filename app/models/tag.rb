class Tag < ApplicationRecord
  # Defining associations
  has_many :article_tags
  has_many :articles, through: :article_tags

  # Defining Validations
  validates :name, presence:true, uniqueness: true
end
