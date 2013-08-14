class Notifications < ActiveRecord::Base
  # attr_accessible :title, :body
  self.primary_key  = "list_id"
  has_one :list, :foreign_key => "ListingId", :primary_key => "list_id"

  def self.add_and_post(listing)
     post_now = false
     return if (listing.Attention == 0) && (listing.NewBuynow == 0)
     return unless self.find_by_list_id(listing.ListingId).nil?


     if listing.Attention == 1
       post_now = true if ((listing.EndDate - Time.now)/3600).to_i < 24
       info = "Pro bid"
     elsif listing.NewBuynow == 1
       post_now = true
       info = "BN added"
     end

     # TODO Add mail notifications here
     rec = Notifications.new
     rec.list_id = listing.ListingId
     rec.done = post_now
     rec.info = info
     rec.save
     NotifymeMailer.fast_notify([rec]).deliver if post_now
  end
end
