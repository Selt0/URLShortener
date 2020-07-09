class Visit < ApplicationRecord
  validates :visitor, :shortened_url, presence: true

  # short hand
  belongs_to :shortened_url

  belongs_to :visitor,
    class_name: :User,
    foreign_key: :user_id,
    primary_key: :id

  def self.record_visit!(user, shortened_url)
    Visit.create!(user_id: user.id, shortened_url_id: shortened_url.id)
  end
end