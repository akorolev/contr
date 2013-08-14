class ListCollector
  LIST_PATH = "Search/General.xml?category=0187-4353&rows=5000&page="
  def collect()
    @oauth_cnt = 0
    status  = false
    begin
      status = catch(:HTTPUnauthorized) do
        status = do_collect
      end
      unless status
        t = Time.now
        t1 = Time.new(t.year, t.month, t.day, t.hour.to_i + 1, 0, 0)
        sleep((t1 - t + 1).to_i)
      end
    end until status
  end

  def db_renew
    @ts = Time.now.to_i
    @tme =TmeOauth.new
    List.all.each do |list_rec|
      if list_rec.PhotoURL.nil?
        update_listing(list_rec, list_rec.ListingId)
      end
    end
  end

  def cleanup_bids
     Bids.group("ListingId").each do |bid_rec|
       Bids.destroy_all("ListingId = #{bid_rec.ListingId}") if List.find_by_ListingId(bid_rec.ListingId).nil?
     end
  end

  def do_collect
    @ts = Time.now.to_i
    @tme =TmeOauth.new
    cnt = 1
    local_cnt = 0
    until (listings = @tme.get(LIST_PATH + cnt.to_s))["SearchResults"]["List"].nil?
      puts("--Page-- " + cnt.to_s)
      listings["SearchResults"]["List"]["Listing"].each do |list_entry|
        process_listing(list_entry)
        puts("Page " + cnt.to_s + "Rec " + (local_cnt += 1).to_s)

      end
      cnt+=1
    end

    cnt = 0
    List.where("TimeStamp != ?", @ts).find_each do |rec_to_arc|
      archive_entry(rec_to_arc)
      cnt += 1
    end
    p "Total to archive " + cnt.to_s

    true
  end

  def archive_entry(rec_to_arc)
    just_delete = false
    if (rec_to_arc.BidCnt > 0) || (rec_to_arc.Attention > 0) || (rec_to_arc.NewBuynow > 0)
      catch(:HTTPBadRequest) do
        update_listing(rec_to_arc, rec_to_arc.ListingId)
      end
    elsif (rec_to_arc.SkipIt > 0) || (rec_to_arc.Repeated)
      just_delete = true
    end
    if rec_to_arc.ReserveMet > 0
      seller = Users.find(rec_to_arc.SellerId)
      seller.Sold += 1
      seller.save!
      if rec_to_arc.BuyerId != 0
        buyer = Users.find(rec_to_arc.BuyerId)
        buyer.Bought += 1
        buyer.save!
      end
    end
    Bids.destroy_all(:ListingId => rec_to_arc.ListingId)
    Notifications.destroy_all(:list_id => rec_to_arc.ListingId)
    unless just_delete
      Archive.create(rec_to_arc.attributes) unless Archive.find_by_ListingId(rec_to_arc.ListingId)
    end
    rec_to_arc.destroy
  end

  def process_listing(entry)
    listing_rec = List.find_or_initialize_by_ListingId(entry['ListingId'])
    if listing_rec.Name.nil? || (listing_rec.Buynow == 0 && entry['BuyNowPrice']) || listing_rec.BidCnt != entry['BidCount'].to_i
       update_listing(listing_rec, entry['ListingId'])
    else
      save_listing_ts(listing_rec)
    end
  end

  def save_listing_ts(listing_rec)
    listing_rec.TimeStamp = @ts
    listing_rec.save!
  end

  def update_listing(listing_rec, id)
    new_rec = listing_rec.Name.nil?
    @oauth_cnt += 1
    p [id, @oauth_cnt]
    detailed = @tme.get("Listings/#{id}.xml")['ListedItemDetail']
    return if (detailed.nil?)
    seller = find_update_seller(detailed['Member'],new_rec)
    if detailed['Bids'].nil?
      bids_info = {:attention => false, :bidder => 0}
    else
      bids_info = process_bids(detailed['ListingId'], detailed['Bids']['List'])
    end

    listing_rec.ListingId = detailed['ListingId']
    listing_rec.Name =detailed['Title']
    listing_rec.SellerId = seller.Id
    listing_rec.EndDate = detailed['EndDate'].to_time
    listing_rec.Value = detailed['PriceDisplay'].gsub(/([,$])/,"")
    listing_rec.BidCnt = detailed['BidCount'].to_i
    listing_rec.BuyerId = bids_info[:bidder]
    listing_rec.ReserveMet= detailed['IsReserveMet'].nil? ? 0 : 1
    listing_rec.Description = detailed['Body']
    listing_rec.ListingURL = "http://www.trademe.co.nz#{detailed['CategoryPath']}/auction-#{detailed['ListingId']}.htm"
    listing_rec.PhotoURL = nested_hash_value(detailed, "Thumbnail")
    listing_rec.SkipIt = seller.SellerRating.to_i < 0 ? 1 : 0
    listing_rec.Attention = (listing_rec.Attention > 0 || seller.SellerRating.to_i > 0 || bids_info[:attention] ) ? 1 : 0
#    listing_rec.NewBuynow = 1 if !new_rec && detailed['Questions'] && listing_rec.Buynow == 0 && entry['BuyNowPrice']
    listing_rec.NewBuynow = 1 if detailed['BuyNowPrice'] && detailed['Questions'] && listing_rec.Buynow == 0 && !new_rec
    listing_rec.Buynow = detailed['BuyNowPrice'].to_s.gsub(/([,$])/,"").to_f
    listing_rec.Repeated = 1 unless Archive.where("Name = ? AND Value = ? AND SellerId = ?", listing_rec.Name, listing_rec.Value, listing_rec.SellerId).empty?
    save_listing_ts(listing_rec)
    Notifications.add_and_post(listing_rec)
  end

  def process_bids(id, bids)
    attention = false
    top_bidder = nil
    if bids['Bid'].kind_of?(Array)
      review_bids = bids['Bid'].sort_by{|s| s["BidAmount"].to_f}.reverse.uniq_by{|u| u["Bidder"]["MemberId"]}
    else
      review_bids = [bids['Bid']]
    end
    review_bids.each do |bid|
      user_rec = find_update_bidder(bid['Bidder'])
      top_bidder = user_rec.id if top_bidder.nil?
      attention = true if user_rec.BuyerRating > 0
      begin
        bid_rec= Bids.find(id, user_rec.id)
        if bid['BidAmount'].to_f > bid_rec.Value.to_f
          bid_rec.Value = bid['BidAmount']
          bid_rec.save!
        end
      rescue
        bid_rec = Bids.new()
        bid_rec.ListingId = id
        bid_rec.User = user_rec.id
        bid_rec.Value = bid['BidAmount']
        bid_rec.save!
      end
    end
    {:attention => attention, :bidder => top_bidder}
  end

  def find_update_bidder(bidder)
    rec = Users.find_or_initialize_by_Name(bidder['Nickname'])
    if rec.Exp.nil? || rec.Exp.to_i != bidder['FeedbackCount']
      rec.Exp = bidder['FeedbackCount']
      rec.save!
    end
    rec
  end

  def find_update_seller(seller, new_listing)
    rec = Users.find_or_initialize_by_Name(seller['Nickname'])
    if new_listing
      rec.Listed = rec.Listed.to_int + 1
      rec.Exp = seller['FeedbackCount']
      rec.save!
    elsif rec.Exp.nil?
      raise("DB error: listing with no seller!")
    end
    rec
  end

  def helpers
    ActionController::Base.helpers
  end
  # Search through XML recs to find a first field matching the key
  def nested_hash_value(obj,key)
    if obj.respond_to?(:key?) && obj.key?(key)
      obj[key]
    elsif obj.respond_to?(:each)
      r = nil
      obj.find{ |*a| r=nested_hash_value(a.last,key) }
      r
    end
  end
end
