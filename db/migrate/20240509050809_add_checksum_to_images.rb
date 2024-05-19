class AddChecksumToImages < ActiveRecord::Migration[6.1]
  def change
    add_column :images, :checksum, :string, default: nil

    add_index :images, :checksum, unique: true
  end
end
