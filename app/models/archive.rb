class Archive < ActiveRecord::Base
  attr_protected
  # attr_accessible :title, :body
  self.table_name = "archive"
  self.primary_key  = "ListingId"
  has_one :seller, :class_name => 'Users', :foreign_key => "Id", :primary_key => "SellerId"
  has_one :buyer, :class_name => 'Users', :foreign_key => "Id", :primary_key => "BuyerId"
end

