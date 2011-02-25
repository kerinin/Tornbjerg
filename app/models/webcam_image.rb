require 'yaml'

class WebcamImage < ActiveRecord::Base
  include ActionView::Helpers::UrlHelper
  
  paperclip_params = YAML::load(File.open("#{RAILS_ROOT}/config/paperclip.yml"))[RAILS_ENV.to_s]
  params = { :styles => { 
      :thumb => '55x40#', 
      :thumb_ds => { :geometry => '55x40#', :processors => [:thumbnail, :modulate], :saturation => 0 }, #[:auto_orient, :thumbnail, :modulate], :saturation => 0 },
      :index => '390x180#', 
      :full => '800x800>',
      :project_description => '400x800>'#,
      #:original => {:processors => [:auto_orient]}
    }, 
    #:processors => [:auto_orient, :thumbnail],
    :default_style => :index,
    :path => "projects/:project_id/webcam_images/:style/:basename.:extension"
    }
    
  has_attached_file :attachment, ( paperclip_params ? params.merge(paperclip_params) : params )
                      
  belongs_to :project
  
  before_validation :download_remote_image, :date_from_url
  
  validates_attachment_presence :attachment, :unless => Proc.new {RAILS_ENV == 'test'}
  validates_presence_of :project
  
  def date_from_url
    r = /(\d{4})(\d{2})(\d{2})(\d{2})(\d{2})(\d{2})(\d+)/
    # [year,month,date,hour,minute,second,ms]
    values = self.source_url.scan(r)
    self.date = DateTime.strptime(values.join(' '), "%Y %m %d %H %M %S")
  end
  
  private
  
  def download_remote_image
    self.attachment = do_download_remote_image
  end

  def do_download_remote_image
    require 'net/ftp'
    ftp = Net::FTP.new('ftp.bcarc.com')
    ftp.login(user = "ftpuser", passwd = "rSW0WstxFTJvNNHP")
    ftp.chdir(self.project.webcam_ftp_dir)
    
    tempfile = Tempfile.new(self.source_url)
    ftp.getbinaryfile(self.source_url, tempfile.path)

    self.attachment = tempfile.path
    self.attachment_file_name = self.source_url
  end
end