class Plan < ActiveRecord::Base
  belongs_to :project
  
  has_many :images
  
  acts_as_list :scope => :project
  
  paperclip_params = YAML::load(File.open("#{Rails.root}/config/paperclip.yml"))[Rails.env.to_s]
  params = { :styles => { :thumb => '55x40#', :full => '800x800>'},
    :default_style => :index,
    :path => "projects/:id/plans/:style/:basename.:extension"
    }
    
  has_attached_file :attachment, ( paperclip_params ? params.merge(paperclip_params) : params )
  
  validates_attachment_presence :attachment, :unless => Proc.new {Rails.env == 'test'}
  validates_presence_of :name, :project_id
  
  #translates :name
  
  scope :by_position, lambda { order(:position) }
  #named_scope :by_position, :order => 'position'
  
  def upload_to_s3
    if self.attachment_file_size.nil?
      begin
        self.attachment = File.new(self.attachment_file_name)
        self.save!
      rescue
        puts "FAIL!!!  #{self.id}"
      else
        puts self.id
      end
    end
  end
end
