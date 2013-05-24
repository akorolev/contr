class List < ActiveRecord::Base
  self.table_name = "lists"
  self.primary_key  = "ListingId"
  has_one :users, :foreign_key => "Id", :primary_key => "SellerId"
  scope :users_included, includes(:users).where("lists.SellerId = users.Id")
end
