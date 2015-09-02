class FacebookAuthenticationService < Aldous::Service

	def initialize(facebook_params)
		@facebook_id = facebook_params[:facebook_id]
		@facebook_acccess_token = facebook_params[:facebook_acccess_token]
	end

	def perform
		facebook_user_object = fetch_facebook_user_object(@facebook_id, @facebook_acccess_token)
		if facebook_user_object.present?
			authenticate_facebook_user(facebook_user_object)
		else
			Result::Failure.new(errors:"Can't Authenticate Facebook User with this acccess token")	
		end
	end 

	private

		def fetch_facebook_user_object(facebook_id,facebook_acccess_token)
			begin
				return FbGraph2::User.new(facebook_id).authenticate(facebook_acccess_token).fetch
			rescue
				return nil
			end
		end
		# return user if facebook_id is found, create new user if not
		def authenticate_facebook_user(facebook_user_object)
			user = User.find_by facebook_id: facebook_user_object.id
			if user.present?
				Result::Success.new(result: user)
			else
				signup_facebook_user(facebook_user_object)
			end
		end

		def signup_facebook_user(facebook_user_object)
			new_user = User.new
			new_user.name = facebook_user_object.name
			new_user.facebook_id = facebook_user_object.id
			if new_user.save
				Result::Success.new(result: new_user)
			else
				Result::Failure.new(errors: new_user.errors)
			end
		end
end