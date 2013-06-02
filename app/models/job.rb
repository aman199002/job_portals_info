class Job < ActiveRecord::Base
  attr_accessible :company, :description, :location, :portal_id, :title, :linkedin_desc, :size
  belongs_to :portal
end
