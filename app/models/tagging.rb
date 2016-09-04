class Tagging < ActiveRecord::Base
  belongs_to :taggable, polymorphic: true
  belongs_to :zone, class_name: City, foreign_key: 'zone_id'
  belongs_to :tag

  EVENTFUL_SOURCE = 'eventful'
  USER_SOURCE = 'user'

  update_index('search#venue') { taggable if taggable_type == 'Venue' }
  update_index('search#event') { taggable if taggable_type == 'Event'  }

  def self.process_eventful_tags tags, object
    [].tap do |taggings|
      ActiveRecord::Base.transaction do
        if tags.is_a? Array
          tags.each do |tag|
            result = add_tag tag, object
            taggings << result if result.present?
          end
        elsif tags.is_a? Hash
          result = add_tag tags, object
          taggings << result if result.present?
        end
      end
    end
  end

  def self.add_tag tag, object
    if tag["title"].present? && tag["title"].is_a?(String)
      existing_tag = tag_by_name(tag["title"])

      unless object.tags.include?(existing_tag)
        create({
          taggable: object,
          tag: existing_tag,
          source: EVENTFUL_SOURCE
        })
      end
    end
  end

  def self.tag_by_name title
    tag_name = title.downcase.strip
    Tag.where(name: tag_name).first_or_create
  end

  def self.add_tag_for_object tag, object
    unless object.tags.include?(tag)
      create({taggable: object, tag: tag, source: USER_SOURCE})
    end
  end

  def self.create_tags_for_event tags, event
    [].tap do |taggings|
      tags.each do |tag|
        existing_tag = tag_by_name(tag)

        if existing_tag.present? && !event.tags.include?(existing_tag)
          taggings << create({
            taggable: event,
            tag: existing_tag,
            source: USER_SOURCE
          })
        end
      end if tags.present?
    end
  end

  def self.remove_tags_for_event tags, event
    [].tap do |taggings|
      tags.each do |tag|
        existing_tag = tag_by_name(tag)

        if existing_tag.present? && event.tags.include?(existing_tag)
          event.taggings.where(tag_id: existing_tag.id).destroy_all
        end
      end if tags.present?
    end
  end

  def self.update_tags_for_event tags, event
    current_tags = event.tags

    tags_to_remove = current_tags.map(&:name) - tags
    remove_tags_for_event(tags_to_remove, event)

    tags_to_add = tags - current_tags
    create_tags_for_event(tags_to_add, event)
  end
end

# == Schema Information
#
# Table name: taggings
#
#  id            :integer          not null, primary key
#  taggable_id   :integer
#  taggable_type :string
#  tag_id        :integer
#  source        :string
#  created_at    :datetime         not null
#  updated_at    :datetime         not null
#
