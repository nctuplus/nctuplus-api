FactoryBot.define do
  factory :background do
    author { create(:user) }
    cover_image do
      Rack::Test::UploadedFile.new(
        Rails.root.join('spec', 'support', 'backgrounds', 'background.jpg'),
        'image/jpeg'
      )
    end
  end
end
