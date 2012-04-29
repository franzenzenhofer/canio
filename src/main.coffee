Canio = {};
Canio._DEBUG_ = _DEBUG_ = true;
#PRIVATE HELPER

#debug helper
dlog = (msg) -> console.log(msg) if _DEBUG_
#dlog = (m) ->
#  return m
#nonblocker helper
nb = (cb, p...) ->
  if cb and typeof cb is 'function'
    window.setTimeout(cb, 0, p...)
  return p?[0]

fff = (params,defaults) ->
  first_func = null
  p2 = []
  i = 0
  while i < params.length or i < defaults.length
    console.log(i)
    if typeof params[i] is 'function' and not first_func
        first_func = params[i]
      else
        if params[i] isnt null and params[i] isnt undefined
          p2.push(params[i])
        else
          p2.push(defaults[i])
    i=i+1
  if not first_func
    throw {name : "NoCallbackGiven", message : "This function needs a callback to work properly"};
    return false
  else
    p2.unshift(first_func)
    dlog(p2)
    return p2



#image data optimized clamp
clamp = (v, min=0, max=255) -> Math.min(max, Math.max(min, v))

#PUBLIC HELPER
#[context, imagedata, imagedata.data] = getToolbox(c)
Canio.getToolbox = getToolbox = (c) ->
  [c, ctx = c.getContext('2d'), img_data = ctx.getImageData(0,0,c.width,c.height), img_data.data]

#takes either width or height as parameters - or - an object with a width and height - and returns a canvas
Canio.make = make = (width=800, height=600, origin) ->
  if width.width and width.height
    element = width
    width = element.width
    height = element.height
    origin = (element?.getAttribute?('id') or element?.getAttribute?('origin'))


  c=document.createElement('canvas')
  c.width=width
  c.height=height
  c.setAttribute('origin', origin) if origin
  return c

Canio.newToolbox = newToolbox = (width, height, origin) -> getToolbox(make(width, height, origin))

Canio.copy = copy = (c, cb) ->
    [new_c,new_ctx] = newToolbox(c)
    new_ctx.drawImage(c,0,0,c.width,c.height)
    nb(cb,new_c)

Canio.byImage = byImage =  (img, cb) ->
  if img.width and img.height
    copy(img, cb)
  else
    img.onload(()->byImage(img,cb))
    return false

Canio.byArray = byArray = (a,w,h,cb) ->
  [c, ctx, imgd, px] = newToolbox(w,h)
  i = 0
  while i < px.length
    cx[i] = a[i]
    i=i+1
  ctx.putImageData(img,0,0)
  nb(cb,c)

Canio.toImage = toImage = (c, cb) ->
  img = new Image()
  img.src=c.toDataURL("image/png", "")
  nb(cb,img)

Canio.toArray = toArray = (c, cb) ->
  a = []
  [c, ctx, imgd, px] = getToolbox(c)
  if Uint8Array then a = new Uint8Array(new ArrayBuffer(px.length))
  i = 0
  while i < px.length
    a[i]=px[i]
    i=i+1
  return a

#toDownload

#resize
Canio.resize = resize = (c, p...) ->
  max =
    width: null
    height: null

  min =
    width: null
    height: null

  [cb, max['width'], max['height'], min['width'], min['height'], first] = fff(p,800, null, null, null, null, null)
  second = null
  r =
    width: null
    height: null

  if first is 'width'
    second = 'height'
  else if first is 'height'
    second = 'width'
  else
    if c.height > c.width
      first='height'
      second='width'
      dlog('hochformat')
    else
      dlog('height'+c.height)
      dlog('width'+c.width)
      first='width'
      second='height'
      dlog('querformat')
  console.log('hallo')
  dlog('first: '+first )
  dlog('second: '+second )
  dlog(c[first])
  #return c
  #scale down
  #w=img.height*(default_width / img.width)
  if max[first] and (c[first] > max[first] or c[second] > max[second])
    dlog('a')
    r[second]=c[second]*max[first]/c[first]
    r[first]=max[first]
    if r[second]>max[second]
      dlog('b')
      r[first]=c[first]*max[second]/c[second]
      r[second]=max[second]

  #scale down
  #if c[first] > max[first]
  #  dlog(first+'>'+max[first])
  #  r[first]=max[first]
  #  r[second]=c[second]*max[first]/c[first]
  #  if r[second] > max[second]
  #
  # #scale up
  else if min[first] and (c[first] < min[first] or c[second] > min[second])
    dlog('c')
    r[first]=c[first] * min[second] / c[second]
    r[second]=min[second]
    if r[first]<min[first]
      dlog('d')
      r[second]=c[second]*min[first]/c[first]
      r[first]=min[first]
  else
    dlog('e')
    r[first]=c[first]
    r[second]=c[second]
    dlog('f')

  #cd.context.drawImage(img, 0,0, newwidth, newheight)
  #dlog('inresizedebugoutput')
  #dlog((c?.getAttribute('id') or c?.getAttribute('source')))
  [new_c, new_ctx]=newToolbox(r.width, r.height, (c?.getAttribute('id') or c?.getAttribute('origin')))
  new_ctx.drawImage(c, 0,0, r.width, r.height)
  dlog('g')
  dlog(new_c)
  dlog(cb)
  return nb(cb, new_c)

Canio.scale = scale = (c, p...) ->
  [cb, x]=fff(p, 1)
  dlog('scale it by '+x)
  new_width = c.width*x
  new_height = c.height*x
  [new_c, new_ctx]=newToolbox(new_width, new_height, (c?.getAttribute('id') or c?.getAttribute('origin')))
  new_ctx.drawImage(c, 0,0, new_width, new_height)
  nb(cb, new_c)

Canio.crop = crop = (c, p...) ->
  [cb, crop_x, crop_y, crop_width, crop_height] = fff(p, 0, 0, c.width/2, c.height/2)
  [new_c, new_ctx]=newToolbox(crop_width, crop_height, (c?.getAttribute('id') or c?.getAttribute('origin')))
  new_ctx.drawImage(c, crop_x, crop_y, crop_width, crop_height, 0,0,crop_width, crop_height)
  nb(cb,new_c)





#multieffects



#EFFECTS
Canio.rotateRight = rotateRight = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(90*Math.PI/180)
  new_ctx.drawImage(c,0,c.height*-1)
  nb(cb,c)

Canio.rotateLeft = rotateLeft = (c,cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(-90*Math.PI/180)
  new_ctx.drawImage(c,c.width*-1,0)
  nb(cb,c)

Canio.flip = flip = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(Math.PI)
  new_ctx.drawImage(c,c.width*-1,c.height*-1)
  nb(cb,c)

Canio.mirror = mirror = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.translate(c2.width / 2,0)
  new_ctx.scale(-1, 1)
  new_ctx.drawImage(c,(c2.width / 2)*-1,0)
  nb(cb,c)

#FILTER

#SIMPLEFILTER

#PRIVATE IMAGE FILTER WRAPPER HELPFER

ifw = (c, cb, image_filters_func, p...) ->
  [c,ctx,imgd, px] = getToolbox(c)
  [new_c,new_ctx,new_imgd, new_px] = newToolbox(c)
  nb(() -> new_ctx.putImageData(image_filters_func(imgd, p...),0,0))
  nb(cb,new_c)

mF = (image_filters_func, defaults...) ->
  return (c, p...) ->
    defaulted_p = fff(p,defaults)
    cb = defaulted_p.shift()
    ifw(c, cb, image_filters_func, defaulted_p...)

#ImageFilters.ConvolutionFilter (srcImageData, matrixX, matrixY, matrix, divisor, bias, preserveAlpha, clamp, color, alpha)

#ImageFilters.Binarize (srcImageData, threshold)
#binarize = (c, cb, threshold=0.5) -> makeIfw(ImageFilters.Binarize, threshold)
#canio.binarize = binarize = (c, p...) -> [cb, threshold] = fff(p, 0.5); return makeIfw(ImageFilters.Binarize, threshold)
Canio.binarize = mF(ImageFilters.Binarize, 0.5)

#ImageFilters.BlendAdd (srcImageData, blendImageData, dx, dy)
#ImageFilters.BlendSubtract (srcImageData, blendImageData, dx, dy)
#ImageFilters.BoxBlur (srcImageData, hRadius, vRadius, quality)
Canio.boxBlur =  mF(ImageFilters.BoxBlur, 3,3,2)

#ImageFilters.GaussianBlur (srcImageData, strength)
Canio.gaussianBlur = mF(ImageFilters.GaussianBlur, 2)

#ImageFilters.StackBlur (srcImageData, radius)
Canio.stackBlur = mF(ImageFilters.StackBlur, 6)

#ImageFilters.Brightness (srcImageData, brightness)
Canio.brightness = mF(ImageFilters.brightness, 1)

#ImageFilters.BrightnessContrastGimp (srcImageData, brightness, contrast)
Canio.brightnessConstrastGimp = mF(ImageFilters.BrightnessContrastGimp, 1,1)
#ImageFilters.BrightnessContrastPhotoshop (srcImageData, brightness, contrast)
Canio.brightnessConstrastPhotoshop = mF(ImageFilters.BrightnessContrastPhotoshop, 1,1)

#ImageFilters.Channels (srcImageData, channel) #3 blue, #2 green
Canio.Channels = (channel_string) ->
  if channel_string is "blue" or channel_string is "b"
    channel = 3
  else if channel_string is "green" or channel_string is "g"
    channel = 2
  else
    channel = channel_string
  mF(ImageFilters.Channels, channel)



#ImageFilters.Clone (srcImageData)
#ImageFilters.CloneBuiltin (srcImageData)
#ImageFilters.ColorMatrixFilter (srcImageData, matrix)
#ImageFilters.ColorTransformFilter (srcImageData, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset)
#ImageFilters.Copy (srcImageData, dstImageData)
#ImageFilters.Crop (srcImageData, x, y, width, height)
#ImageFilters.CropBuiltin (srcImageData, x, y, width, height)
#ImageFilters.Desaturate (srcImageData)
#ImageFilters.DisplacementMapFilter (srcImageData, mapImageData, mapX, mapY, componentX, componentY, scaleX, scaleY, mode)
#ImageFilters.Dither (srcImageData, levels)
#ImageFilters.Edge (srcImageData)
#ImageFilters.Emboss (srcImageData)
#ImageFilters.Enrich (srcImageData)
#ImageFilters.Flip (srcImageData, vertical)
#ImageFilters.Gamma (srcImageData, gamma)
#ImageFilters.GrayScale (srcImageData)
#ImageFilters.HSLAdjustment (srcImageData, hueDelta, satDelta, lightness)
#ImageFilters.Invert (srcImageData)
Canio.invert = invert = mF(ImageFilters.Invert)
#ImageFilters.Mosaic (srcImageData, blockSize)
Canio.mosaic = mosaic = mF(ImageFilters.Mosaic, 10)
#ImageFilters.Oil (srcImageData, range, levels)
#ImageFilters.OpacityFilter (srcImageData, opacity)
#ImageFilters.Posterize (srcImageData, levels)
#ImageFilters.Rescale (srcImageData, scale)
#ImageFilters.Resize (srcImageData, width, height)
#ImageFilters.ResizeNearestNeighbor (srcImageData, width, height)
#ImageFilters.Sepia srcImageData)
#ImageFilters.Sharpen (srcImageData, factor)
#ImageFilters.Solarize (srcImageData)
#ImageFilters.Transpose (srcImageData)
#ImageFilters.Twril (srcImageData, centerX, centerY, radius, angle, edge, smooth)
#

#export
window.Canio = Canio

