class AddFieldsToEvents < ActiveRecord::Migration
  def change
    execute %{CREATE TYPE event_kind AS ENUM('public', 'private') }

    change_table :events do |t|
      t.references :user, index: true
      t.column :kind, :event_kind, default: "public"
    end
  end
end
