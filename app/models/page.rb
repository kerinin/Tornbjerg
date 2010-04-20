class Page < ActiveRecord::Base
  #has_permalink :name
  make_permalink :with => :name
  
  acts_as_wikitext :content
  
  acts_as_list
  
  translates :name, :content
  
  default_scope :order => 'position ASC'
end
