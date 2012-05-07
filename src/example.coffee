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

  #viewfinder border
  $(img).on('canvasready', (e,c)->
    Canio.viewfinder(c, (c) ->
      $('#viewfinder_placeholder').html(c)
      )
    )

  #oldschool border
  $(img).on('canvasready', (e,c)->
    Canio.oldschool(c, (c) ->
      $('#oldschool_placeholder').html(c)
      )
    )
  #many
  $(img).on('canvasready', (e,c)->
    actions =[ Canio.curve,  Canio.scale, Canio.screen, Canio.saturate, Canio.vignette, Canio.oldschool, Canio.toImage]
    params = [[],0.8,[227, 12, 169, 0.40],0.9,[0.2, 0.8],[],[]]
    Canio.many(c,actions, params, (c) ->
      $('#many_placeholder').html(c)
      )
    )

  #oil
  $(img).on('canvasready', (e,c)->
    oilbutton = $('<button>Click Me!</button>').on('click', () ->
      Canio.oil(c, 4, 30, (c) ->$('#oil_placeholder').html(c)
      )
    )
    $('#oil_placeholder').html(oilbutton)
  )

  #oil
  $(img).on('canvasready', (e,c)->
    button = $('<button>Click Me!</button>').on('click', () ->
      Canio.removeNoise(c, (c) ->$('#removenoise_placeholder').html(c)
      )
    )
    $('#removenoise_placeholder').html(button)
  )
#c64 = "0,0,0 255,255,255 116,67,53 124,172,186 123,72,144 100,151,79 64,50,133 191,205,122 123,91,47 79,69,0 163,114,101 80,80,80 120,120,120 164,215,142 120,106,189 159,159,159".split(" ");
  #schemer border
  $(img).on('canvasready', (e,c)->
    Canio.schemer(c,
      [127,255],
      [127,255],
      [127,255],
      [],
      [0,255],
      [255,0],
      [0,0],
      (c) ->
        $('#schemer_placeholder').html(c)
      )
    )

  #reduceAndReplace
  $(img).on('canvasready', (e,c)->
    Canio.reduceAndReplace(c, 8, (c) ->
      $('#reduceandreplace_placeholder').html(c)
      )
    )

  #create the starting canvas
  Canio.byImage(img,(c) ->
    $('#byImage_placeholder').html(c)
    c.id='canvasbyimage'
    $(img).trigger('canvasready', c)
    )

  #Canio.byImage($('#viewfinder')[0],(c) ->
  #  Canio.toImage(c, (ii)->
  #    $('#byImage_placeholder').html(ii)
  #    )
  #  )
  #  $('#byImage_placeholder').html(c)
  #  #c.id='canvasbyimage'
 #  Canio.resize(c, 400, 400, (c) ->
  #  #$(img).trigger('canvasready', c)

  #    )
  #  )
  #todo when a canvas gets created, throw an event

#  Canio.byImage(img,(c)->
#    Canio.resize(c, 400,300, 200, 100, (c) ->
#      console.log('hallo')
#      dlog(c)
#      $('#resize_placeholder').html(c)
#      )
#    )
)
