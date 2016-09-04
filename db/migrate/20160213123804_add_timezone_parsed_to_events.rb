class AddTimezoneParsedToEvents < ActiveRecord::Migration
  def change
    add_column :events, :timezone_parse_at, :datetime, default: nil, index: true
  end
end
