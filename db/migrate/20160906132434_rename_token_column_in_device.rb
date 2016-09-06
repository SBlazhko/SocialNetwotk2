class RenameTokenColumnInDevice < ActiveRecord::Migration[5.0]
  def change
    rename_column :devices, :token, :push_token
  end
end
