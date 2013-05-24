class Archive < ActiveRecord::Base
  attr_protected
  # attr_accessible :title, :body
  self.table_name = "archive"
  self.primary_key  = "ListingId"

end

