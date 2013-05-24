# Place all the behaviors and hooks related to the matching controller here.
# All this logic will automatically be available in application.js.
# You can use CoffeeScript in this file: http://jashkenas.github.com/coffee-script/

dt = undefined
$ ->
  dt = $('#lists').dataTable
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
    sAjaxSource: $('#lists').data('source')

$('#lists tbody td').live 'click', ->
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
  sOut += "<tr><td>"+mData.source+"</td><td rowspan='3'>"+mData.large_photo+"</td></tr>"
  sOut += "<tr><td>"+mData.bids+"</td></tr>"
  sOut += "<tr><td>"+mData.listed+" "+mData.sold+" "+mData.seller_exp+"</td></tr>"
  sOut += "<tr><td colspan='2'>"+mData.description+" </td></tr>"
  sOut += "</table>"
  sOut

$ ->
  $("#time_filter").buttonset()
  $("#listing_filter").buttonset()
  $("input[type=submit]").button()
  $(".trigger").click ->
    $(".panel").toggle "fast"
    $(this).toggleClass "active"
    false

