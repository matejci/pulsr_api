class EventsPerformers < ActiveRecord::Migration
  def change
    create_table :events_performers, id: false do |t|
      t.belongs_to :event, index: true
      t.belongs_to :performer, index: true
    end

    add_index :events_performers, [:event_id, :performer_id], :unique => true
  end
end
