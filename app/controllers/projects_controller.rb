Mime::Type.register 'application/vnd.google-earth.kml+xml', :kml

class ProjectsController < ApplicationController
  #resource_controller
  
  #actions :show, :index
  
  caches_action :show, :cache_path => Proc.new { |c| c.params.merge( {:version => c.read_fragment("project_#{c.params[:project_id]}")} ).delete_if { |k,v| k.starts_with?('utm_') } }

  def index
    @projects = Project.active.where(:priority => 1..3).sample( 6 )
    
    respond_to do |format|
      format.html # index.html.erb
    end
  end
  
  def show
    @project = Project.find(params[:id])
    @object = @project
    
    if @project.images.active.count > 1
      @next = @project.images.active[1]
    elsif @project.videos.count
      @next = @project.videos[0]
    end
    
    if @project.has_webcam && !@project.webcam_images.empty?
      @prev = @project.webcam_images.first
    end
    
    response.headers['Cache-Control'] = "public, max-age=600"
    
    respond_to do |format|
      format.html # index.html.erb
      format.kml
      format.js
    end
  end
     
  def map
    @project = Project.find(params[:id])
    #load_object     # From resource_controller
    
    redirect_to project_path( @project ) and return unless @project.show_map && @project.latitude && @project.longitude
    
    @map = GMap.new( "map_div" )
    @map.control_init( :large_map => true )
    @map.center_zoom_init( [@project.latitude,@project.longitude], @project.map_accuracy + 3 )
    @map.overlay_init( GMarker.new( [@project.latitude,@project.longitude], :title => @project.name ) )
    
    render :action => :map
  end
  
  def webcam
    @project = Project.find(params[:id])
    #load_object

    @next = @project

    respond_to do |format|
      format.html { render :action => :webcam }
      format.js
    end
  end
end
