class CreateJobs < ActiveRecord::Migration
  def change
    create_table :jobs do |t|
      t.integer :portal_id
      t.string :title
      t.text :description
      t.string :location
      t.string :company

      t.timestamps
    end
  end
end
