class UserCauseRelationship < ActiveRecord::Base
	belongs_to :user
	belongs_to :cause
end
