class CreateCalls < ActiveRecord::Migration
  def change
    create_table :calls do |t|
      t.integer :count, default: 0
    end
  end
end
