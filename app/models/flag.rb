class Flag < ActiveRecord::Base
  include Locationable

  belongs_to :flaggable, polymorphic: true
  belongs_to :user

  before_save :check_flaggable

  private

  def check_flaggable
    unless latitude.present?
      if flaggable.is_a?(Photo)
        self.latitude = flaggable.latitude
        self.longitude = flaggable.longitude

        if flaggable.data.present? && flaggable.data['meta_content'].present?
          self.data['type'] = flaggable.data['meta_content']['import_type']
        end
      end
    end
  end
end

# == Schema Information
#
# Table name: flags
#
#  id             :integer          not null, primary key
#  user_id        :integer
#  flaggable_id   :integer
#  flaggable_type :string
#  data           :jsonb
#  latitude       :decimal(, )
#  longitude      :decimal(, )
#  lonlat         :geography({:srid point, 4326
#  created_at     :datetime         not null
#  updated_at     :datetime         not null
#
