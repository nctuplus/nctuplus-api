class User < ActiveRecord::Base
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable and :omniauthable
  # TODO: configure omniauth for devise_token_auth
  # https://devise-token-auth.gitbook.io/devise-token-auth/configuration/omniauth
  devise :trackable, :omniauthable, omniauth_providers: %i[nctu facebook google_oauth2]
  include DeviseTokenAuth::Concerns::User

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
end
