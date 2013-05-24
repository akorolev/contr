class Bids < ActiveRecord::Base
  # attr_accessible :title, :body
  self.table_name = "bids"
  self.primary_keys= :ListingId, :User
  belongs_to :users, :foreign_key => "User", :primary_key => "Id"
end
