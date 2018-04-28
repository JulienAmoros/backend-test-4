class CreateCalls < ActiveRecord::Migration[5.1]
  def change
    create_table :calls do |t|
      t.string :uid
      t.string :status
      t.string :from
      t.string :final_action
      t.integer :duration
      t.string :recording_url
      t.integer :recording_duration

      t.timestamps
    end
  end
end
