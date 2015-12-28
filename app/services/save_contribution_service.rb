class SaveContributionService < Aldous::Service
	
	def initialize(amount, user)
		@amount = amount
		@user = user
		@cause = Cause.find_by(id:@user.current_cause_id)
	end

	def perform
		puts "SAVE CONTRIBUTION SERVICE!!!"
		contribution = Contribution.new
		contribution.amount = @amount
		puts "contributing: "+@amount.to_s
		contribution.user_id = @user.id
		contribution.user_name = @user.name
		contribution.cause_id = @cause.id
		if contribution.save
			update_all
			Result::Success.new(result: contribution)
		else
			puts "SAVE CONTRIBUTION ERRORS"
			Result::Failure.new(errors: contribution.errors)
		end
	end

	private 

	#TODO: Figure out what happens if one of these updates fail and how to handle it

	def update_all
		update_user
		update_user_cause_relationship
	end

	def update_user
		@user.increment!(:total_amount_contributed, @amount)
		@user.update_attribute(:last_contribution_date, Time.now)
		puts "incrementing amount: "+@amount.to_s+" by 1"
		@user.increment!(:current_cause_amount_contributed, @amount)
		puts "successfully incremented amount"
		@user.increment!(:total_contributions, 1)
	end

	def update_user_cause_relationship
		relationship = UserCauseRelationship.where(:user_id => @user.id).where(:cause_id => @cause.id).first
		relationship.increment!(:amount_contributed, @amount)
		puts "increment relationship amount "+ relationship.amount_contributed.to_s
		relationship.update_attribute(:last_contribution_date, Time.now)
		if !relationship.has_contributed
			puts "new contribution, create new relationship "
			@cause.increment!(:number_of_contributors,1)
			relationship.update_attribute(:has_contributed,true)
		end
	end

end