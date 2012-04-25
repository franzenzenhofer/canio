$(window).load(() ->
  console.log('HI')
  _DEBUG_ = true
  dlog = (msg) -> console.log msg if _DEBUG_
  #dlog('DEBUG MODUS')
  img = $('#testimage')[0]
  Canio.byImage(img,(c)->$('#byImage_placeholder').html(c))
  #todo when a canvas gets created, throw an event

  Canio.byImage(img,(c)->
    dlog(c)
    Canio.resize(c, 500,400, (c) ->
      console.log('hallo')
      dlog(c)
      $('#resize_placeholder').html(c)
      )
    )
)
