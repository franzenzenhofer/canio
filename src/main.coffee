_DEBUG_ = true

#Canio, the object we will export in the final scope
Canio = {}
#PRIVATE HELPER

#debug helper
dlog = (msg) -> console.log msg if _DEBUG_

#nonblocker helper
nb = (cb, p...) ->
  if cb
    window.setTimeout(cb, 0, p...)
  return p[0]

fff = (params,defaults) ->
  first_func = null
  p2 = []
  i = 0
  while i < params.length or i < defaults.length
    if typeof params[i] is 'function' and not first_func
        first_func = x
      else
        if params[i] isnt null and params[i] isnt undefined
          p2.push(x)
        else
          p2.push(defaults[i])
  if not first_func
    throw {name : "NoCallbackGiven", message : "This function needs a callback to work properly"};
    return false
  else
    return p2.unshift(first_func)



#image data optimized clamp
clamp = (v, min=0, max=255) -> Math.min(max, Math.max(min, v))

#PUBLIC HELPER
#[context, imagedata, imagedata.data] = getToolbox(c)
Canio.getToolbox = getToolbox = (c) ->
  [ctx = c.getContext('2d'), img_data = ctx.getImageData(0,0,c.width,c.height), img_data.data]

#takes either width or height as parameters - or - an object with a width and height - and returns a canvas
Canio.make = make = (width=800, height=600) ->
  if width.width and width.height
    element = width
    width = element.width
    height = element.height

  c=document.createElement('canvas')
  c.width=width
  c.height=height
  return c

Canio.newToolbox = newToolbox = (width, height) -> getToolbox(make(width, height))

Canio.copy = copy = (c, cb) ->
    [new_c,new_ctx] = s.newToolbox(c)
    ctx.drawImage(c,0,0,c.width,c.height)
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
  max = {}
  min = {}
  [cb, max['width'], max['height'], min['width'], min['height'], first] = fff(p,800,600, 0,0, undefined)
  second = undefined
  r = {}

  if first is 'width'
    second = 'height'
  else if first is 'height'
    second = 'width'
  else
    if c.height > c.width
      first='height'; second='width'
    else
      first='width'; second='height'

  #scale down
  #w=img.height*(default_width / img.width)
  if c[first] > max[first] or c[second] > max[second]
    r[first]=c[second]*max[first]/c[first]
    r[second]=max[second]
    if r[first]>max[first]
      r[second]=c[first]*max[second]/c[second]
      r[first]=max[first]
  #scale up
  else if c[first] < min[first] or c[second] > min[second]
    r[first]=c[second]*min[first]/c[first]
    r[second]=min[second]
    if r[first]<min[first]
      r[second]=c[first]*min[second]/c[second]
      r[first]=min[first]
  else
    r[first]=c[first]
    r[second]=c[second]

  #cd.context.drawImage(img, 0,0, newwidth, newheight)
  [new_c, new_ctx]=newToolbox(r.width, r.height)
  new_ctx.drawImage(c, 0,0, r.width, r.height)
  nb(new_c)




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
Canio.invert = invert = makeIfw(ImageFilters.Invert)
#ImageFilters.Mosaic (srcImageData, blockSize)
Canio.mosaic = mosaic = makeIfw(ImageFilters.Mosaic, 10)
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

