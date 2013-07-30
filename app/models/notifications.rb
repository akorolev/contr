class Notifications < ActiveRecord::Base
  # attr_accessible :title, :body
  self.primary_key  = "list_id"
  has_one :lists, :foreign_key => "ListingId", :primary_key => "list_id"

  def self.add_and_post(id, info)
     post_now = 0

     if info[:attention]
       listing = List.find_by_ListingId(id)
       return if (listing.nil?)
       message = "Pro bidder"
       post_now = 1 if ((listing.EndDate - Time.now)/3600).to_i < 24
     elsif info[:new_buy_now]
       message = "Buy now added"
       post_now = 1
     else
       message = "Error"
     end

     # TODO Add mail notifications here
     rec = self.find_or_initialize_by_list_id(id)
#     rec.list_id = id
     rec.info = message if (rec.info.nil?)
     rec.done = post_now
     rec.save!
  end
end
