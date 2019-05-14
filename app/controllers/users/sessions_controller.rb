class Users::SessionsController < DeviseTokenAuth::SessionsController
  include ActionController::Cookies
  def destroy
    # remove auth instance variables so that after_action does not run
    user = remove_instance_variable(:@resource) if @resource
    client_id = remove_instance_variable(:@client_id) if @client_id
    remove_instance_variable(:@token) if @token

    if user && client_id && user.tokens[client_id]
      user.tokens.delete(client_id)
      user.save!

      yield user if block_given?
      cookies.clear
      redirect_to "https://#{Rails.configuration.frontend_hostname}"
    else
      redirect_to "https://#{Rails.configuration.frontend_hostname}/login"
    end
  end
end
