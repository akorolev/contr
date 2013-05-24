require "datatables.rb"

class UsersController < ApplicationController
  @@filter_params ||= {:filter_sold_from => "0", :filter_sold_to => "9999", :filter_bought_from => "0", :filter_bought_to => "9999"}

  def index
    params.merge!(@@filter_params)
    #puts YAML::dump(@@filter_params)
    respond_to do |format|
      format.html
      format.json do
        @users  = UsersDatatable.new(@@filter_params, view_context)
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
    @@filter_params = params
    respond_to do |format|
      format.html { redirect_to(:action => 'index') }
      format.json { redirect_to(:action => 'index') }
    end
  end

  def show
    @display_bids = !Bids.find_all_by_User(params[:id]).empty?
    @user = Users.find(params[:id])
  end
  def show_bids
    respond_to do |format|
      format.html
      format.json do
        @user_bids  = UserBidsDatatable.new(params, view_context)
        render :json => @user_bids
      end
    end
  end

  def edit
  end
end
