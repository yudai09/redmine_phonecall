class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.integer :count, default: 0, null: false
      t.timestamps null: false
    end
  end
end
