module Flaggable
  extend ActiveSupport::Concern

  included do
    has_many :flags, as: :flaggable, dependent: :destroy
  end

  def flag(data)
    data[:flaggable] = self

    if data[:message].present?
      data[:data] = data.delete(:message)
    end

    Flag.create(data)
  end
end