class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  include ActionController::Cookies
  def redirect_callbacks
    if cookies[:logged_in] == 'true'
      puts 'Perform account binding'
      account_binding
    else
      puts 'Perform account log in procedure'
      log_in_procedure
    end
  end

  def omniauth_success
    redirect_callbacks
  end

  # Implement login procedure
  def log_in_procedure
    set_user
    if !@user.nil?
      @user.update_tracked_fields!(request)
      set_cookies(access_token_object: @user.create_new_auth_token, provider: @user.provider, user_name: @user.name)
      redirect_to "https://#{Rails.configuration.fronted_hostname}/users"
    else
      render json: { 'Error': 'Something went wrong' }
    end
  end

  # Implement account binding
  def account_binding
    set_base_user
    redirect_path = check_binding_availability
    redirect_url = "https://#{Rails.configuration.fronted_hostname}"
    # redirect_path is nil means base user supports account binding
    if redirect_path.nil?
      redirect_url.insert(-1, '/users')
      auth_record = case request.env['omniauth.auth'][:provider]
                    when 'facebook'
                      AuthFacebook.create_record_from_oauth2(request.env['omniauth.auth'])
                    when 'google_oauth2'
                      AuthGoogle.create_record_from_oauth2(request.env['omniauth.auth'])
                    end
      auth_record.original_user_data_transferring(new_user_id: @base_user.id)
      auth_record.update(user: @base_user)
    else
      redirect_url.insert(-1, redirect_path)
    end
    redirect_to redirect_url
  end

  def failure
    redirect_to "https://#{Rails.configuration.fronted_hostname}/login"
  end

  private

  def set_user
    # Set login user
    uid = request.env['omniauth.auth'][:uid]
    provider = request.env['omniauth.auth'][:provider]
    auth_record = case provider
                  when 'nctu'
                    AuthNctu.create_record_from_oauth2(request.env['omniauth.auth'])
                  when 'facebook'
                    AuthFacebook.create_record_from_oauth2(request.env['omniauth.auth'])
                  when 'google_oauth2'
                    AuthGoogle.create_record_from_oauth2(request.env['omniauth.auth'])
                  end
    @user = if auth_record.nil?
              nil
            else
              # Find the associated user by provider and uid(student_id)
              auth_record.find_or_initialize_user_by_uid_provider(uid: uid)
            end
  end

  def set_base_user
    @base_user = User.find_by(uid: cookies.encrypted[:_uid])
  end

  # Check binding availability of base user, if ok return nil else return the redirect path with error code
  def check_binding_availability
    if @base_user.nil?
      # base user does not exist
      '/users?error=0'
    elsif !@base_user.check_user_session_valid?(access_token: cookies[:access_token], client_id: cookies[:client])
      # base user session expires, need re-login
      cookies.clear
      '/login?error=0'
    elsif !@base_user.support_account_binding?
      # base user does not support account binding
      '/users?error=1'
    elsif @base_user.check_repeat_account_binding?(provider: request.env['omniauth.auth'][:provider])
      # repeat account binding
      '/users?error=2'
    end
  end

  def set_cookies(access_token_object:, provider:, user_name:)
    common_fields = { expires: 1.hours, secure: true }
    cookies.encrypted[:_uid] = common_fields.merge(value: access_token_object['uid'], httponly: true)
    cookies[:access_token]   = common_fields.merge(value: access_token_object['access-token'])
    cookies[:client]         = common_fields.merge(value: access_token_object['client'])
    cookies[:expiry]         = common_fields.merge(value: access_token_object['expiry'])
    cookies[:uid]            = common_fields.merge(value: access_token_object['uid'])
    cookies[:provider]       = common_fields.merge(value: provider)
    cookies[:logged_in]      = common_fields.merge(value: true, httponly: true)
    cookies[:name]           = common_fields.merge(value: user_name)
  end
end
