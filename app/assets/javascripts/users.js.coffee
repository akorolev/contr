# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/
jQuery ->
  $('.best_in_place').best_in_place()

dt = undefined
$ ->
  dt = $('#users').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    aaSorting: [[0, "asc"]]
    aoColumns: [
      mData: "name"
      sWidth: "200px"
    ,
      mData: "experience"
      sWidth: "50px"
    ,
      mData: "bought"
      sWidth: "50px"
    ,
      mData: "sold"
      sWidth: "50px"
    ,
      mData: "listed"
      sWidth: "50px"
    ,
      mData: "sell_ratio"
      sWidth: "50px"
    ,
      mData: "rated"
      sWidth: "50px"
    ,
      mData: "buyer_rating"
      sWidth: "50px"
    ,
      mData: "seller_rating"
      sWidth: "50px"

    ]
    sAjaxSource: $('#users').data('source')

$ ->
  dt = $('#users_bids').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    aaSorting: [[5, "desc"]]
    aoColumns: [
      mData: "met"
      sWidth: "20px"
    ,
      mData: "name"
      bSortable: false
      sWidth: "280px"
    ,
      mData: "value"
      sWidth: "70px"
    ,
      mData: "bidcnt"
      sWidth: "7px"
    ,
      mData: "photo"
      bSortable: false
      sWidth: "70px"
    ,
      mData: "ending"
      sWidth: "120px"
    ,
      mData: "seller"
      sWidth: "100px"
    ,
      mData: "sell_ratio"
      sWidth: "50px"
    ,

    ]
    sAjaxSource: $('#users_bids').data('source')
