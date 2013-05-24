require "datatables.rb"
class ListsController < ApplicationController
  def index
    @@filter_params ||= Hash.new
    params.merge!(@@filter_params)
    respond_to do |format|
      format.html
      format.json do
        @lis  = ListsDatatable.new(@@filter_params, view_context)
        render :json => @lis
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
    @list = List.find(params[:ListingId])
  end
end
