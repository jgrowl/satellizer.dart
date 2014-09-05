class CreateIdentities < ActiveRecord::Migration

  def change
    create_table :identities do |t|
      t.string :uid
      t.string :provider
      t.references :user
    end

    add_index :identities, :user_id
  end
end
