# 紀錄收藏課程
class UsersCourse < ApplicationRecord
  belongs_to :user
  belongs_to :course
end
