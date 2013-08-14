require "datatables.rb"

class UsersController < ApplicationController

  def index
    p "+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-+!-"
    respond_to do |format|
      format.html
      format.json do
        @users  = UsersDatatable.new(params, view_context)
        render :json => @users
      end
    end
  end

  def update
    respond_to do |format|
      format.html
      format.json do
        @user = Users.find(params[:id])
        @user.update_attributes(params[:users])
        respond_with_bip(@user)
      end
    end
  end

  def filter_panel
    redirect_to :action => 'index',
                :filter_sold_from => params[:filter_sold_from],
                :filter_sold_to => params[:filter_sold_to],
                :filter_bought_from => params[:filter_bought_from],
                :filter_bought_to => params[:filter_bought_to],
                :filter_with_bids => params[:filter_with_bids]
  end

  def show
    @user = Users.find(params[:id])

    @selectable_table = []

    sorted = [true, false, true, true, false, true, true]
    header = %w[Met Name Value Bidcnt Photo Ending Seller]
    width = %w[6% 30% 12% 6% 20% 14% 12%]

    @selectable_table.push({:label => "Bids", :disabled => Bids.find_all_by_User(@user.Id).empty?, :active => false, :header => header, :sorted => sorted, :width => width})
    @selectable_table.push({:label => "Bought", :disabled => @user.Bought.zero?, :active => false, :header => header, :sorted => sorted, :width => width})
    @selectable_table.push({:label => "Sold", :disabled => @user.Sold.zero?, :active => false, :header => header.take(6).push("Buyer"), :sorted => sorted, :width => width})
    @selectable_table.push({:label => "Listings", :disabled => List.find_all_by_SellerId(@user.Id).empty?, :active => false, :header => header.take(6).push("TopBidder"), :sorted => sorted.take(6).push(false), :width => width})

    @selectable_table.each do |opt|
      next if opt[:disabled]
      if params[:select_table].nil?
        opt[:active] = true
        break
      elsif params[:select_table]==opt[:label]
        opt[:active] = true
      end
    end
  end

  def select_table
    redirect_to(:action => 'show', :select_table => params[:select_table])
  end

  def show_info_table
    respond_to do |format|
      format.html
      format.json do
        @user_info_table  = UserBidsDatatable.new(params, view_context) if (params[:infotype] == "Bids")
        @user_info_table  = UserBoughtDatatable.new(params, view_context) if (params[:infotype] == "Bought")
        @user_info_table  = UserListingsDatatable.new(params, view_context) if (params[:infotype] == "Listings")
        @user_info_table  = UserSoldDatatable.new(params, view_context) if (params[:infotype] == "Sold")
        render :json => @user_info_table
      end
    end
  end

  def edit
  end
end
