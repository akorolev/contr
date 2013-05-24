class Users < ActiveRecord::Base
  # attr_accessible :title, :body
  attr_accessible :Rated, :BuyerRating, :SellerRating
  self.table_name = "users"
  has_many :lists, :foreign_key => "SellerId"

  def sell_ratio
    self.Listed.to_i > 0 ? self.Sold.to_i * 100 / self.Listed.to_i  : 0
  end
end
