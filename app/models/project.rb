class Project < ActiveRecord::Base  
  has_many :images, :order => 'position'
  has_many :videos, :order => 'position'
  has_many :plans, :order => 'position'
  
  belongs_to :thumbnail, :class_name => 'Image'
  
  has_and_belongs_to_many :tags
  
  #has_permalink :name
  make_permalink :with => :name
  
  acts_as_wikitext :description
  
  translates :name, :short, :description
  
  def year
    self.date_completed.strftime('%Y')
  end
end
