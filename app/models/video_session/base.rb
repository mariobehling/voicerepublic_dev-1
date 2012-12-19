class VideoSession::Base < ActiveRecord::Base
  attr_accessible :begin_timestamp, :end_timestamp, :klu_id,:klu, :video_system_session_id, :calling_user_id, :type, :canceling_participant_id
  attr_accessor :calling_user_id
  attr_accessor :canceling_participant_id
  
  has_many :notifications, :class_name => 'Notification::Base', :foreign_key => 'video_session_id'
  has_one :video_room, :autosave => true, :foreign_key => 'video_session_id', :dependent => :delete
  belongs_to :klu, :inverse_of => :video_sessions
    
  validates_presence_of :klu 
  validates_presence_of :calling_user_id, :on => :create
  
  
  def is_rateable?
    self.instance_of?(VideoSession::Registered) && self.klu.instance_of?(Kluuu) && enough_time_passed?
  end
  
  private
  
  # enough time to create a rating?
  #
  def enough_time_passed?
    (end_timestamp - begin_timestamp) > 3.minutes
  end

end