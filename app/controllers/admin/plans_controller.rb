class Admin::PlansController < Admin::BaseController
  resource_controller
  
  belongs_to :project
  
  actions :all
  
  create.wants.html { redirect_to edit_admin_project_plan_path(@project,@plan) }
  update.wants.html { redirect_to edit_admin_project_plan_path(@project,@plan) }
  destroy.wants.html { redirect_to admin_project_plans_path(@project) }
  
  private
  
  def collection
    end_of_association_chain
  end
  
  def object
    @object ||= end_of_association_chain.find_by_param!(param) unless param.nil?
    @object
  end
  
  def parent_object
    parent? && !parent_singleton? ? parent_model.find_by_param!(parent_param) : nil
  end
end
