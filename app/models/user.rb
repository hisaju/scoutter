class User < ApplicationRecord
  authenticates_with_sorcery!
  has_one_attached :icon

  has_many :sum_power

  has_many :power_levels
  has_many :authentications, dependent: :destroy

  belongs_to :character

  validates :name, presence: true
  validates :twitter_id, presence: true

  scope :power_rank, -> do
    joins(:sum_power)
      .includes(:character, :sum_power)
      .with_attached_icon
      .order('sum_powers.power desc')
  end
  scope :total_period, -> { merge(SumPower.total) }
  scope :week_period, -> { merge(SumPower.week) }
  scope :day_period, -> { merge(SumPower.day) }
end
