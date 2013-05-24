class EmptyDatatable

  def initialize(filters,view)
    p "Filters ----------------------------------------"
    p filters.inspect
    p "----------------------------------------Filters "
    @filters =filters
    @view = view
  end

  def as_json(options = {})
    {
      sEcho: params[:sEcho].to_i,
      iTotalRecords: recs.count,
      iTotalDisplayRecords: recs.total_entries,
      aaData: data
    }
  end

private
  def recs
    @recs ||= fetch_recs
  end

  def page
    params[:iDisplayStart].to_i/per_page + 1
  end

  def per_page
    params[:iDisplayLength].to_i > 0 ? params[:iDisplayLength].to_i : 10
  end

  def sort_column
    columns[params[:iSortCol_0].to_i]
  end

  def sort_direction
    params[:sSortDir_0] == "desc" ? "desc" : "asc"
  end
end


class ListsDatatable < EmptyDatatable
  delegate :logger, :params, :h, :image_tag, :link_to, :number_to_currency, to: :@view
  private

  def columns
    %w[lists.ReserveMet lists.Name lists.Value lists.BidCnt lists.PhotoURL lists.EndDate users.Name (users.Sold)/(users.Listed)]
  end

  def data
    recs.map do |listing|
#      puts YAML::dump(caller)
      {
          :met => listing.ReserveMet > 0 ? image_tag("flag.gif") : 0,
          :name => h(listing.Name),
          :value => number_to_currency(listing.Value),
          :bidcnt => listing.BidCnt,
          :photo => image_tag(listing.PhotoURL),
          :ending => h(listing.EndDate.strftime("%a, %e %b %H:%M")),
          :seller => link_to(listing.users.Name, listing.users),
          :sell_ratio => listing.users.sell_ratio,
          :seller_exp =>h("Exp: "+ listing.users.Exp.to_s),
          :listed => h("Listed: "+ listing.users.Listed.to_s),
          :sold => h("Sold: "+ listing.users.Sold.to_s),
          :rating => h("Rating: "+ listing.users.SellerRating.to_s  ),
          :large_photo => '<img src="'+h(listing.PhotoURL).sub("thumb", "tq")+'">',
          :source => link_to(listing.ListingId,listing.ListingURL),
          :description => h(listing.Description),
          :bids => listing.BidCnt > 0 ? "Bidders:<br>" + Bids.where("ListingId = ?", listing.ListingId).map{|bid| link_to(bid.users.Name, listing.users)}.join("<br>") : " "
      }
    end
  end

  def fetch_recs
    puts YAML::dump(@filters.inspect)
#    lists = List.includes(:users).where("users.Name = lists.Seller").order("users.Id ASC")
    lists = List.users_included.order("#{sort_column} #{sort_direction}")
    lists = lists.page(page).per_page(per_page)
    logger.info(lists)
    if params[:sSearch].present?
      lists = lists.where("lists.name like :search or lists.seller like :search", search: "%#{params[:sSearch]}%")
    end
    if @filters[:buy_now_filter].present?
      lists = lists.where("lists.NewBuynow > 0")
    end
    if @filters[:repeated_filter].present?
      lists = lists.where("lists.Repeated = 0")
    end
    if @filters[:filter_time] == "finish_8"
      lists = lists.where("lists.EndDate < ?", Time.now + 3600 * 8)
    end
    if @filters[:filter_time] == "finish_24"
      lists = lists.where("lists.EndDate < ?", Time.now + 3600 * 24)
    end

    lists
  end

end

class UsersDatatable < EmptyDatatable
  delegate :logger, :link_to, :params, :h, :image_tag, :best_in_place, to: :@view
  private

  def columns
    %w[users.Name users.Exp users.Bought users.Sold users.Listed (users.Sold)/(users.Listed) users.Rated users.BuyerRating users.SellerRating]
  end

  def data

    recs.map do |user|
      {
          :name => link_to(user.Name, user),
          :experience => user.Exp,
          :bought => user.Bought,
          :sold => user.Sold,
          :listed => user.Listed,
          :sell_ratio => user.sell_ratio,
          :rated => best_in_place(user, :Rated, :type => :select, :collection => [[0, "unrated"], [1, "rated"]]),
          :buyer_rating => best_in_place(user, :BuyerRating, :type => :select, :collection => [[-1, "silly"], [0, "normal"], [1, "pro"], [2, "expert"]]),
          :seller_rating => best_in_place(user, :SellerRating, :type => :select, :collection => [[-1, "greedy"], [0, "normal"], [1, "worthy"]]),
      }
    end
  end

  def fetch_recs
    recs = Users.order("#{sort_column} #{sort_direction}")
    recs = recs.page(page).per_page(per_page)
    recs = recs.where("users.Sold >= ? and users.Sold <= ? and users.Bought >= ? and users.Bought <= ?",
                      @filters[:filter_sold_from].to_i, @filters[:filter_sold_to].to_i,
                      @filters[:filter_bought_from].to_i, @filters[:filter_bought_to].to_i)
    if params[:sSearch].present?
      recs = recs.where("users.name like :search", search: "%#{params[:sSearch]}%")
    end
    recs
  end

end

class UserBidsDatatable < ListsDatatable

  def fetch_recs
    bids = Bids.where("User = ?",params[:id])
    listing_ids = bids.map{|a|  a.ListingId.to_i}
    p "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa"
    p listing_ids

    lists = List.users_included.order("#{sort_column} #{sort_direction}")
    lists = lists.where('lists.ListingId in (?)',listing_ids)
    lists = lists.page(page).per_page(per_page)

    if params[:sSearch].present?
      lists = lists.where("lists.name like :search or lists.seller like :search", search: "%#{params[:sSearch]}%")
    end
    p lists.inspect
    p "bbbbbbbbbbbbbbbbbbbbbbbbbbbbbbbb"
    lists
  end
end
