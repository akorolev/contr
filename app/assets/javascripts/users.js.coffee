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
    fnServerParams: (aoData) ->
      aoData.push
        name: "filter_sold_from"
        value: $('#filter_sold_from').val()
      ,
        name: "filter_sold_to"
        value: $('#filter_sold_to').val()
      ,
        name: "filter_bought_from"
        value: $('#filter_bought_from').val()
      ,
        name: "filter_bought_to"
        value: $('#filter_bought_to').val()

$ ->
  user_info_columns = []
  i = 0
  while i < datatableheaders.length
    user_info_columns[i] =
      mData: datatableheaders[i]
      bSortable: datatablesorted[i]
      sWidth: datatablewidth[i]
    i++

  dt = $('#user-info').dataTable
    sPaginationType: "full_numbers"
    bJQueryUI: true
    bProcessing: true
    bServerSide: true
    aaSorting: [[5, "desc"]]
    aoColumns: user_info_columns
    sAjaxSource: $('#user-info').data('source')
    fnServerParams: (aoData) ->
      aoData.push
        name: "infotype"
        value: $('#user-info').data('infotype')

$(document).on "click", "#user-info tbody td", ->
  nTr = $(this).parents('tr')[0]
  if dt.fnIsOpen(nTr)
    dt.fnClose nTr
    return
  openRows = dt.fnSettings().aoOpenRows;
  if (openRows.length > 0)
    dt.fnClose openRows[0].nParent
  dt.fnOpen nTr, fnFormatDetails(nTr), 'details'


fnFormatDetails = (nTr) ->
  mData = dt.fnGetData(nTr)
  #   console.log(mData)
  sOut = "<table cellpadding=\"5\" cellspacing=\"0\" border=\"0\" style=\"padding-left:10px;\">"
  sOut += "<tr><td>"+mData.source+"</td><td rowspan='2'>"+mData.large_photo+"</td></tr>"
  sOut += "<tr><td>"+mData.listed+" "+mData.sold+" "+mData.seller_exp+"</td></tr>"
  sOut += "<tr><td colspan='2'>"+mData.description+" </td></tr>"
  sOut += "</table>"
  sOut

