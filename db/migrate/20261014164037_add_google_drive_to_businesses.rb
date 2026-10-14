class AddGoogleDriveToBusinesses < ActiveRecord::Migration[8.1]
  def change
    add_column :businesses, :google_drive_connected, :boolean, default: false
    add_column :businesses, :google_drive_folder_id, :string
    add_column :businesses, :google_drive_access_token, :text
    add_column :businesses, :google_drive_refresh_token, :text
    add_column :businesses, :google_drive_token_expires_at, :datetime
    add_column :businesses, :google_drive_email, :string

    add_column :expenses, :google_drive_file_id, :string
    add_column :expenses, :google_drive_file_url, :string

    add_column :invoices, :google_drive_file_id, :string
    add_column :invoices, :google_drive_file_url, :string
  end
end
