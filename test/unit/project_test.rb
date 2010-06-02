require File.dirname(__FILE__) + '/../test_helper'



# NOTE: test associated get deleted


class ProjectTest < ActiveSupport::TestCase
  context "Projects" do
    setup do
      @active = Factory :project
      @no_photos = Factory :project
      @no_tags = Factory :project
      
      @image1 = Factory :image, :project => @active
      @image2 = Factory :image, :project => @no_tags
      
      @tag1 = Factory :tag, :projects => [@active, @no_photos]
    end
    
    teardown do
      Project.delete_all
      Image.delete_all
      Tag.delete_all
    end
    
    should "not return projects w/o images in named scope 'active'" do
      assert_does_not_contain Project.active.all, @no_photos
    end
    
    should "not return projects w/o tags in named scope 'active'" do
      assert_does_not_contain Project.active.all, @no_tags
    end
  end
  
  context "A project" do
    setup do
      @completed = 1.year.ago
      
      @project = Factory :project, 
        :name => 'Test Project',
        :description => 'Project Description',
        :short => 'Short Description',
        :date_completed => @completed,
        :address => '100 5th Street',
        :city => 'San Francisco',
        :state => 'CA',
        :priority => 5,
        :thumbnail => Factory(:image)
        
      @plan1 = Factory :plan, :project => @project
      @plan2 = Factory :plan, :project => @project
      
      @video1 = Factory :video, :project => @project
      @video2 = Factory :video, :project => @project
      
      @tag = Factory :tag
      
      @project.tags << @tag
    end
    
    teardown do
      Plan.delete_all
      Image.delete_all
      Video.delete_all
      Tag.delete_all
      Project.delete_all
    end
  
    should "have some values" do
      assert_equal @project.name, 'Test Project'
      assert_equal @project.description, 'Project Description'
      assert_equal @project.short, 'Short Description'
      assert_equal @project.date_completed, @completed
      assert_equal @project.address, '100 5th Street'
      assert_equal @project.city, 'San Francisco'
      assert_equal @project.state, 'CA'
      assert_equal @project.priority, 5
    end
    
    should "have associated plans" do
      assert @project.plans.include? @plan1
      assert @project.plans.include? @plan2
      assert_equal @plan1.project, @project
      assert_equal @plan2.project, @project
    end
    
    should "have associated images" do
      @image1 = Factory :image, :project => @project
      @image2 = Factory :image, :project => @project
      
      assert @project.images.include? @image1
      assert @project.images.include? @image2
      assert_equal @image1.project, @project
      assert_equal @image2.project, @project
    end
    
    should "have associated videos" do
      assert @project.videos.include? @video1
      assert @project.videos.include? @video2
      assert_equal @video1.project, @project
      assert_equal @video2.project, @project
    end
    
    should "have associated tags" do
      assert @project.tags.include? @tag
      assert @tag.projects.include? @project
    end
    
    should "not geocode if map=false" do
      @project.address = '1111 East 11th Street'
      @project.city = 'Austin'
      @project.state = 'TX'
      @project.save!
      
      assert @project.latitude.blank?
      assert @project.longitude.blank?
    end
          
    should_eventually "pull geocoded lat/lon on address save if map=true" do
      @project.show_map = true
      @project.address = '1111 East 11th Street'
      @project.city = 'Austin'
      @project.state = 'TX'
      @project.save!
      
      assert @project.latitude == 30.268807
      assert @project.longitude == -97.728902
      assert @project.map_accuracy == 8
    end
 
    should "save the first attached image as the thumbnail if none specified" do
      @project2 = Factory :project
      @image = Factory :image
      @project2.images << @image
      
      assert_equal @image, @project2.thumbnail
    end
    
    should "i18n description" do
      I18n.locale = :en
      @project.description = 'English'
      I18n.locale = :fr
      @project.description = 'French'
      
      assert @project.description = 'French'
      I18n.locale = :en
      assert @project.description = 'English'
    end
    
    should "i18n name" do
      I18n.locale = :en
      @project.name = 'English'
      I18n.locale = :fr
      @project.name = 'French'
      
      assert @project.name = 'French'
      I18n.locale = :en
      assert @project.name = 'English'
    end
    
    should "not update permalink if name chaned for other locale" do
      perm = @project.permalink
      I18n.locale = :fr
      @project.name = "Another Name in French"
      @project.save!
      
      assert_equal perm, @project.permalink
    end
  end
end
