class RegistrationsController < ApplicationController
  include RestApiMethods

  before_filter :authenticate_user!
  before_filter :require_authorization!

  respond_to :html, :json

  layout 'cmu_sv_no_pad'

  def index
    @registrations = Registration.scoped_by_params(params)

    respond_with @registrations
  end

  # Get #bulk_import
  def bulk_import
    
  end
  
  # Placeholder object for query regarding students not assigned to teams. We'll need to fix this.
  def students_not_assigned_to_teams
	@people = Person.find(:all, :conditions=>"is_student=false")
  end
  
  	# GET /courses/:id/registrations/find_unregistered_students_for_course
	def find_unregistered_students_for_course
		registrations = Registration.find(:all, :conditions => ["id = ?",params[:id]])
		registration_ids = Array.new
		registrations.each do |registered_id|
			registration_ids << registered_id.person_id
		end
		@nonregistered_users = Person.find(:all,:conditions => ["id not in (?)",registration_ids])
	end

  # def new
  #   
  # end

  # def create
  #   
  # end

  # def update
  #   
  # end

  # def edit
  #   
  # end

  # def destroy
  #   
  # end

  # def show
  #   
  # end

  private

  def require_authorization!
    render :nothing => true, :status => :unauthorized unless current_user.permission_level_of(:staff)
  end
end