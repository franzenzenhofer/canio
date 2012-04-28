$(window).load(() ->
  console.log('HI')
  _DEBUG_ = true
  dlog = (msg) -> console.log msg if _DEBUG_
  #dlog('DEBUG MODUS')
  img = $('#testimage')[0]
  #$(img).bind('canvasready', (e, c)->)
  #
  # as we want to keep the examples here kinda consisten to what is in the documentation
  # we implement lots and lots of 'canvasready' eventlistener, in real life you wouldn't do this this way.
  $(img).on('canvasready', (e,c)->
    Canio.resize(c, 400,300, 200, 100, (c) ->
      c.id='resizedcanvas'
      $('#resize_placeholder').html(c)
      )
    )

  Canio.byImage(img,(c) ->
    $('#byImage_placeholder').html(c)
    c.id='canvasbyimage'
    $(img).trigger('canvasready', c)
    )
  #todo when a canvas gets created, throw an event

#  Canio.byImage(img,(c)->
#    Canio.resize(c, 400,300, 200, 100, (c) ->
#      console.log('hallo')
#      dlog(c)
#      $('#resize_placeholder').html(c)
#      )
#    )
)
