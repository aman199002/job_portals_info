class AddLinkedinDescAndSizeToJobs < ActiveRecord::Migration
  def change
    add_column :jobs, :linkedin_desc, :text
    add_column :jobs, :size, :string
  end
end
