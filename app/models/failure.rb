
# Model for tracking failed events from workers
class Failure < ActiveRecord::Base
end

# == Schema Information
#
# Table name: failures
#
#  id         :integer          not null, primary key
#  name       :string
#  data       :json
#  error      :string
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
