class CreateStories < ActiveRecord::Migration
  def change
    create_table :stories do |t|
      #t.integer :story_id, uniq: true
      #t.string :title
      t.string :url
      t.boolean :read

      t.timestamps
    end

    #add_index :stories, :story_id
  end
end
