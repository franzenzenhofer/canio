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

  $(img).on('canvasready', (e,c)->
    Canio.scale(c, 0.1, (c) ->
      c.id='scaledcanvas'
      $('#scale_placeholder').html(c)
      )
    )

  $(img).on('canvasready', (e,c)->
    Canio.crop(c, 580, 330, 100, 100, (c) ->
      c.id='cropedcanvas'
      $('#crop_placeholder').html(c)
      )
    )

  $(img).on('canvasready', (e,c)->
    Canio.invert(c, (c) ->
      $('#invert_placeholder').html(c)
      )
    )

  $(img).on('canvasready', (e,c)->
    Canio.mosaic(c, 8, (c) ->
      $('#mosaic_placeholder').html(c)
      )
    )

  $(img).on('canvasready', (e,c)->
    Canio.binarize(c, 0.5, (c) ->
      $('#binarize_placeholder').html(c)
      )
    )

  $(img).on('canvasready', (e,c)->
    Canio.noise(c, 90, (c) ->
      $('#noise_placeholder').html(c)
      )
    )
  #vignette
  $(img).on('canvasready', (e,c)->
    Canio.vignette(c, 0.2, 0.8, (c) ->
      $('#vignette_placeholder').html(c)
      )
    )
  #saturate
  $(img).on('canvasready', (e,c)->
    Canio.saturate(c, 0.2, (c) ->
      $('#saturate_placeholder').html(c)
      )
    )
  #desaturate
  $(img).on('canvasready', (e,c)->
    Canio.desaturate(c, 0.4, (c) ->
      $('#desaturate_placeholder').html(c)
      )
    )
  #curve
  $(img).on('canvasready', (e,c)->
    Canio.curve(c, (c) ->
      $('#curve_placeholder').html(c)
      )
    )
  #screen
  $(img).on('canvasready', (e,c)->
    Canio.screen(c, 227, 12, 169, 0.9, (c) ->
      $('#screen_placeholder').html(c)
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
