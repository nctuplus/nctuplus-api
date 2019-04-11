class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # TODO: configure omniauth for devise_token_auth
  # https://devise-token-auth.gitbook.io/devise-token-auth/configuration/omniauth
  devise :database_authenticatable, :trackable, :omniauthable, omniauth_providers: %i[nctu facebook google_oauth2]
  include DeviseTokenAuth::Concerns::User

  has_one :auth_nctu, dependent: :nullify
  has_one :auth_facebook, dependent: :nullify
  has_one :auth_google, dependent: :nullify

  has_many :users_events
  has_many :events, through: :users_events
  has_many :users_courses
  has_many :backgrounds, foreign_key: :author_id
  has_many :bulletins, foreign_key: :author_id, inverse_of: :author
  has_many :slogans, foreign_key: :author_id, inverse_of: :author
  has_many :courses, through: :users_courses
  has_many :course_ratings
  has_many :comments
  has_many :past_exams, foreign_key: :uploader_id
  has_many :books
  has_many :timetables
  has_many :scorses

  validates :name, length: { maximum: 16, message: '姓名過長(max:16)' }

  def auth_nctu?
    auth_nctu.present?
  end

  def auth_facebook?
    auth_facebook.present?
  end

  def auth_google?
    auth_google.present?
  end

  def support_account_binding?
    provider == 'nctu'
  end

  def check_repeat_account_binding?(provider:)
    case provider
    when 'facebook'
      auth_facebook?
    when 'google_oauth2'
      auth_google?
    when 'nctu'
      auth_nctu?
    else
      true
    end
  end
end
