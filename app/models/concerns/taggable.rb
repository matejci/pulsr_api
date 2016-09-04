module Taggable
  extend ActiveSupport::Concern

  included do
    has_many :taggings, as: :taggable, dependent: :destroy
    has_many :tags, through: :taggings do
      def <<(tag)
        Tagging.add_tag_for_object(tag, proxy_association.owner)

        proxy_association
      end
    end

    scope :with_tags, -> { includes(:taggings).where.not(taggings: {taggable_id: nil}) }
    scope :with_no_tags, -> { includes(:taggings).where(taggings: {taggable_id: nil}) }
  end

end