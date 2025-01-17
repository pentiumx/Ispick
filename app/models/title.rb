class Title < ActiveRecord::Base
  has_many :people_titles, dependent: :destroy
  has_many :people, :through => :people_titles
  validates_uniqueness_of :name_english
end
