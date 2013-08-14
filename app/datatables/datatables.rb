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

  def std_rec_helper(rec)
    {
    :met => rec.ReserveMet > 0 ? image_tag("flag.gif") : 0,
    :name => h(rec.Name),
    :value => number_to_currency(rec.Value),
    :bidcnt => rec.BidCnt,
    :photo => image_tag(rec.PhotoURL),
    :ending => h(rec.EndDate.strftime("%a, %e %b %H:%M")),
    :large_photo => '<img src="'+h(rec.PhotoURL).sub("thumb", "tq")+'">',
    :source => link_to(rec.ListingId,rec.ListingURL),
    :description => h(rec.Description),
    }
  end

  def data
    recs.map do |rec|
        out = {
          :seller => link_to(rec.users.Name, rec.users),
          :sell_ratio => rec.users.sell_ratio,
          :seller_exp =>h("Exp: "+ rec.users.Exp.to_s),
          :listed => h("Listed: "+ rec.users.Listed.to_s),
          :sold => h("Sold: "+ rec.users.Sold.to_s),
          :rating => h("Rating: "+ rec.users.SellerRating.to_s  ),
          :bids => rec.BidCnt > 0 ? "Bidders:<br>" + Bids.where("ListingId = ?", rec.ListingId).map{|bid| link_to(bid.users.Name, bid.User.to_s)}.join("<br>") : " "
        }
      std_rec_helper(rec).merge(out)
    end
  end

  def fetch_recs
    lists = List.users_included.order("#{sort_column} #{sort_direction}")
    lists = lists.page(page).per_page(per_page)
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
    puts YAML::dump(params.inspect)
    if @filters[:filter_with_bids] == "checked"
      recs = Users.joins(:bids).uniq
    else
      recs = Users
    end
    recs = recs.order("#{sort_column} #{sort_direction}").page(page).per_page(per_page)
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

    lists = List.users_included.order("#{sort_column} #{sort_direction}")
    lists = lists.where('lists.ListingId in (?)',listing_ids)
    lists = lists.page(page).per_page(per_page)

    if params[:sSearch].present?
      lists = lists.where("lists.name like :search or lists.seller like :search", search: "%#{params[:sSearch]}%")
    end
    lists
  end
end

class  UserListingsDatatable < ListsDatatable
  delegate :logger, :params, :h, :image_tag, :link_to, :number_to_currency, to: :@view
  private

  def columns
    %w[lists.ReserveMet lists.Name lists.Value lists.BidCnt lists.PhotoURL lists.EndDate]
  end

  def data
    recs.map do |rec|
      out = {
          :topbidder => rec.BidCnt > 0 ? Bids.where("ListingId = ?", rec.ListingId).map{|bid| link_to(bid.users.Name, bid.User.to_s)}.join("<br>") : " "
      }
      std_rec_helper(rec).merge(out)
    end
  end

  def fetch_recs

    lists = List.where("SellerId = ?", params[:id]).order("#{sort_column} #{sort_direction}")
    lists = lists.page(page).per_page(per_page)
    if params[:sSearch].present?
      lists = lists.where("lists.name like :search", search: "%#{params[:sSearch]}%")
    end
    lists
  end
end

class  UserSoldDatatable < ListsDatatable
  delegate :logger, :params, :h, :image_tag, :link_to, :number_to_currency, to: :@view
  private

  def columns
    %w[archive.ReserveMet archive.Name archive.Value archive.BidCnt archive.PhotoURL archive.EndDate users.Name]
  end

  def data
      recs.map do |rec|
        out = {
          :buyer =>  rec.BuyerId > 0 ? link_to(rec.buyer.Name, rec.buyer.Id.to_s) : " "
        }
        std_rec_helper(rec).merge(out)
    end
  end

  def fetch_recs
    lists = Archive.includes(:buyer).where("archive.BuyerId = users.Id or archive.BuyerId = 0").order("#{sort_column} #{sort_direction}").where("SellerId = ?", params[:id])
    lists = lists.page(page).per_page(per_page)
    if params[:sSearch].present?
      lists = lists.where("archive.name like :search", search: "%#{params[:sSearch]}%")
    end
    lists
  end
end

class  UserBoughtDatatable < ListsDatatable
  def columns
    %w[archive.ReserveMet archive.Name archive.Value archive.BidCnt archive.PhotoURL archive.EndDate users.Name]
  end

  def data
    recs.map do |rec|
      out = {
          :seller => link_to(rec.seller.Name, rec.SellerId.to_s),
          :sell_ratio => rec.seller.sell_ratio,
          :seller_exp =>h("Exp: "+ rec.seller.Exp.to_s),
          :listed => h("Listed: "+ rec.seller.Listed.to_s),
          :sold => h("Sold: "+ rec.seller.Sold.to_s),
          :rating => h("Rating: "+ rec.seller.SellerRating.to_s  ),
          :bids => rec.BidCnt > 0 ? "Bidders:<br>" + Bids.where("ListingId = ?", rec.ListingId).map{|bid| link_to(bid.users.Name, bid.User.to_s)}.join("<br>") : " "
      }
      std_rec_helper(rec).merge(out)
    end
  end

  def fetch_recs
    lists = Archive.joins(:seller).order("#{sort_column} #{sort_direction}")
    lists = lists.where('archive.BuyerId = (?)',params[:id])
    lists = lists.page(page).per_page(per_page)

    if params[:sSearch].present?
      lists = lists.where("archive.Name like :search or seller.Name like :search", search: "%#{params[:sSearch]}%")
    end
    lists
  end
end
