class CreateImages < ActiveRecord::Migration
  def change
    create_table :images do |t|
      t.string :title
      t.string :caption
      t.string :face_feature
      t.string :src_url

      t.timestamps
    end
  end
end
