class User < ActiveRecord::Base

acts_as_authentic

  
#  acts_as_authentic do |c|
#  end
  
#  validates_presence_of     :login
  validates_length_of       :login,    :within => 3..40
  validates_uniqueness_of   :login,    :case_sensitive => false, :allow_nil => true

#  validates_presence_of     :email
  validates_length_of       :email,    :within => 6..100 #r@a.wk
#  validates_uniqueness_of   :email,    :case_sensitive => false

  validates_uniqueness_of   :webiso_account,    :case_sensitive => false, :allow_nil => true

  # HACK HACK HACK -- how to do attr_accessible from here?
  # prevents a user from submitting a crafted form that bypasses activation
  # anything else you want your user to change should be added here.
  attr_accessible :login, :email, :password, :password_confirmation, :first_name, :last_name, :webiso_account, :isStaff, :isStudent, :isAdmin, :twiki_name, :photo, :strength1_id, :strength2_id, :strength3_id, :strength4_id, :strength5_id

  
  # Lines modified by Todd go here:
  before_save :initialize_human_name
   has_and_belongs_to_many :teams

#  belongs_to :person
#  def is_student?
#    person.is_student?
#  end
#  def is_staff?
#    person.is_staff?
#  end


  def emailed_recently(email_type)
    case email_type
      when :effort_log
        return self.effort_log_warning_email.nil? || (self.effort_log_warning_email < 1.day.ago) ? false : true
      when :sponsored_project_effort
        return self.sponsored_project_effort_last_emailed.nil? || (self.sponsored_project_effort_last_emailed < 1.day.ago) ? false : true
    end
  end

  #This method contributed by Team Juran
  def faculty_teams_map(person_id = self.id)
    faculty_teams = Team.find_by_sql(["SELECT t.* FROM  teams t WHERE t.primary_faculty_id = ? OR t.secondary_faculty_id = ?", person_id, person_id])

    teams_map = {}
    teams_students_map = {}
    for team in faculty_teams
      if teams_map[team.course.year].nil?
        teams_map[team.course.year] = {}
        teams_students_map[team.course.year] = {}
      end
      if teams_map[team.course.year][team.course.semester.downcase].nil?
        teams_map[team.course.year][team.course.semester.downcase] = []
        teams_students_map[team.course.year][team.course.semester.downcase] = 0
      end
      teams_map[team.course.year][team.course.semester.downcase].push(team)
      teams_students_map[team.course.year][team.course.semester.downcase] += team.people.count
    end
    # teams_map is a two dimentional hash holding arrays of courses
    # teams_students_map is a two dimentional hash holding an integer count
    # of students that are part of the courses for a given semester
    return [teams_map, teams_students_map]
  end


  def permission_level_of(role)
    case role
      when :student
        return (self.is_student? || self.is_staff? || self.is_admin?)
      when :staff
        return (self.is_staff? || self.is_admin?)
      when :admin
        return (self.is_admin?)
      else
        return false
    end
  end

  protected
 def initialize_human_name
   self.human_name = self.first_name + " " + self.last_name if self.human_name.nil?
 end



end
