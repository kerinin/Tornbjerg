require File.dirname(__FILE__) + '/../test_helper'

class ImagesControllerTest < ActionController::TestCase
  context "Given data" do
    setup do
      @project = Factory :project
      
      @image1 = Factory :image, :project => @project, :position => 1
      @image2 = Factory :image, :project => @project, :position => 2
      @image3 = Factory :image, :project => @project, :position => 3
      @deleted_image = Factory :image, :project => @project
      @deleted_image.destroy
      
      @video1 = Factory :video, :project => @project
      @video2 = Factory :video, :project => @project
      
      @project.thumbnail = @image1
      @project.save!
    end
    
    teardown do
      Project.delete_all
      Image.delete_all
      Video.delete_all
    end
    
    should_route :get, '/Project/:project_id/Images/:id', :controller => :images, :action => :show, :project_id => ':project_id', :id => ':id', :locale => :en
    
    context "on GET to :show from project" do
      setup do
        get :show, :project_id => @project.to_param, :id => @image1.to_param
      end
      should_respond_with :success
      should_assign_to :tags
      
      should "assign the image" do
        assert assigns['image'] == @image1
      end
    end
    
    context "on GET to :show from project for deleted image" do
      setup do
        get :show, :project_id => @project.to_param, :id => @deleted_image.to_param
      end
      should_respond_with :success
      should_assign_to :image, :next
      should_not_assign_to :prev
      
      should "assign the image" do
        assert_equal @deleted_image, assigns['image']
      end
      
      should "assign second project image to 'next'" do
        assert_equal @image2, assigns['next']
      end
    end
    
    context "on GET to :show from project with legacy URLs" do
      setup do
        previous_param = @project.to_param
        
        @project.name = 'New Name 1'
        @project.save!
        second_param = @project.to_param
        
        @project.name = 'New Name 2'
        @project.save!
        
        get :show, :project_id => previous_param, :id => @image1.to_param
      end
      should_respond_with :success
      
      should "find the project from original" do
        assert assigns['project'] == @project
      end
    end
    
    context "on GET to :show from project with another legacy URL" do
      setup do
        previous_param = @project.to_param
        
        @project.name = 'New Name 1'
        @project.save!
        second_param = @project.to_param
        
        @project.name = 'New Name 2'
        @project.save!
        
        get :show, :project_id => second_param, :id => @image1.to_param
      end
      should_respond_with :success
      
      should "find the project from second" do
        assert assigns['project'] == @project
      end
    end
  end
end
