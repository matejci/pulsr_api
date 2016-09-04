class Tag < ActiveRecord::Base
  has_many :taggings, dependent: :destroy
  has_many :events, through: :taggings, source: :taggable, source_type: 'Event'
  has_many :venues, through: :taggings, source: :taggable, source_type: 'Venue'
  has_many :performers, through: :taggings, source: :taggable, source_type: 'Performer'
  has_and_belongs_to_many :tastes

  scope :query_by_name, -> query { where('name ~* ?', ["^#{query}"]).order('name') }
  scope :is_public, -> { where(hidden: false) }
  scope :by_regex, -> (regex) { where('name ~* ?', [regex]) }

  update_index('search#venue') { venues }
  update_index('search#event') { events }

  def as_json(*)
    {
      id: id,
      name: name
    }
  end


end

# == Schema Information
#
# Table name: tags
#
#  id         :integer          not null, primary key
#  name       :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
