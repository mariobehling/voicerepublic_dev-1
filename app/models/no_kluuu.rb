class NoKluuu < Klu
  has_many :bookmarks, :dependent => :destroy, :foreign_key => :klu_id
  before_create :init
  
  def init
    self.published = true
    self.charge_type = 'free'
  end
end
