Canio = {};
Canio._DEBUG_ = _DEBUG_ = false;

#PRIVATE HELPER

#debug helper
dlog = (msg) -> console.log(msg) if _DEBUG_
#some functions can't work without callback
cbr = (cb,function_name) -> until cb then throw new Error('Callback required for '+function_name)

#stupid isfunction check
isFunction = (functionToCheck) ->
  getType = {}
  return functionToCheck and getType.toString.call(functionToCheck) is '[object Function]'

#nonblocker helper
nb = (cb, p...) ->
  if cb and isFunction(cb)
    window.setTimeout(cb, 0, p...)
  return p?[0]

fff = (params,defaults...) ->
  first_func = null
  p2 = []
  i = 0
  while i < params.length or i < defaults.length
    if typeof params[i] is 'function' and not first_func
        first_func = params[i]
      else
        if params[i] isnt null and params[i] isnt undefined
          p2.push(params[i])
        else
          p2.push(defaults[i])
    i=i+1
  if not first_func
    # throw {name : "NoCallbackGiven", message : "This function needs a callback to work properly"};
    # return false
    # we return a dummy callback
    first_func = (c)->null
  p2.unshift(first_func)
  dlog(p2)
  return p2

#private image data optimized clamp
clamp = (v, min=0, max=255) ->Math.min(max, Math.max(min, v))
#END PRIVATE HELPFER

#PUBLIC HELPER
#all PUBLIC HELPER are availabe via a Canio method and via an internal function name
#[context, imagedata, imagedata.data] = getToolbox(c)
Canio.getToolbox = getToolbox = (c,cb) ->
  nb(cb, [c, ctx = c.getContext('2d'), img_data = ctx.getImageData(0,0,c.width,c.height), img_data.data])

#takes either width or height as parameters - or - an object with a width and height - and returns a canvas
Canio.make = make = (p...) ->
  [cb, width, height, origin]=fff(p,800,600)
  if width.width and width.height
    element = width
    width = element.width
    height = element.height
    origin = (element?.getAttribute?('id') or element?.getAttribute?('origin'))


  c=document.createElement('canvas')
  c.width=width
  c.height=height
  c.setAttribute('origin', origin) if origin
  nb(cb,c)

Canio.newToolbox = newToolbox = (p...) ->
  [cb, width, height, origin] = fff(p)
  Canio.getToolbox(make(width, height, origin),cb)

Canio.copy = copy = (c, cb) ->
    [new_c,new_ctx] = newToolbox(c)
    new_ctx.drawImage(c,0,0,c.width,c.height)
    nb(cb,new_c)

Canio.byImage = byImage =  (img, cb) ->
  if img.width and img.height
    #dlog('imgwidth and imgheight are given in byImage')
    copy(img, cb)
  else
    #dlog('width and height are not given')
    cbr(cb, 'Canio.byImage (only if the image is not "loaded")')
    if isFunction(cb)
      img.onload = ()->Canio.byImage(img,cb)
    return true

Canio.byArray = byArray = (a,w,h,cb) ->
  [c, ctx, imgd, pxs] = newToolbox(w,h)
  i = 0
  while i < pxs.length
    pxs[i] = a[i]
    i=i+1
  ctx.putImageData(imgd,0,0)
  nb(cb,c)

Canio.toImage = toImage = (c, p...) ->
  [cb, mime]=fff(p, 'image/png')
  img = new Image()
  img.src=c.toDataURL(mime, "")
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


Canio.hardResize = hardResize = (c, w, h, cb) ->
  [new_c, new_ctx]=Canio.newToolbox(w, h)
  new_ctx.drawImage(c, 0, 0, w, h)
  nb(cb,new_c)

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

#RGBAFILTER

Canio.rgba = rgba = (c, p...) ->
  dlog('inrgba')
  #dlog(p)
  [cb, filter, extended] = fff(p, null, false)
  dlog(typeof filter)
  if not isFunction(filter)
    dlog('filter not a function')
    return false
  [c, ctx, imgd, pxs] = getToolbox(c)
  [w,h]=[c.width,c.height]
  dlog('rgba canvas size')
  dlog([w,h])
  u8 = new Uint8Array(new ArrayBuffer(pxs.length))
  y = 0
  dlog('rgbabeforewhile')
  while y < h
    x = 0
    while x < w
      i = (y*w + x) * 4
      r = i
      g = i+1
      b = i+2
      a = i+3
      if not extended
        [u8[r],u8[g],u8[b],u8[a]] = filter(pxs[r],pxs[g],pxs[b],pxs[a], i)
      else
        [u8[r],u8[g],u8[b],u8[a]] = filter(pxs[r],pxs[g],pxs[b],pxs[a], i, c)
      x=x+1
    y=y+1
  new_c = Canio.byArray(u8, w,h)
  dlog('rgba return value')
  dlog(new_c)
  nb(cb, new_c)


#toDownload
#


#multieffects



#EFFECTS
# EFFECTS are only available via a Canio method
Canio.rotateRight = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(90*Math.PI/180)
  new_ctx.drawImage(c,0,c.height*-1)
  nb(cb,c)

Canio.rotateLeft =  (c,cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(-90*Math.PI/180)
  new_ctx.drawImage(c,c.width*-1,0)
  nb(cb,c)

Canio.flip = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.rotate(Math.PI)
  new_ctx.drawImage(c,c.width*-1,c.height*-1)
  nb(cb,c)

Canio.mirror = (c, cb) ->
  [new_c, new_ctx] = newToolbox(c)
  new_ctx.translate(c2.width / 2,0)
  new_ctx.scale(-1, 1)
  new_ctx.drawImage(c,(c2.width / 2)*-1,0)
  nb(cb,c)

#FILTER

#SIMPLEFILTER
#
#
#Canvas.overlay(canvas, canvas2, alpha, callback)
#Canvas.overlay = (c, p...) ->
#  [cb, c2, alpha] = fff(p, null, 0.5)
#  if not c2
#    return false
#TODO
#
#Canio.noise(c, amount, callback) #amount 0 to n





Canio.noise = (c, p...) ->
  [cb, amount]=fff(p,20)
  [new_c, new_ctx, new_imgd, new_pxs]=getToolbox(copy(c))
  for px, i in new_pxs
    noise = Math.round(amount - Math.random() * amount/2)
    dblHlp = 0
    k=0
    while k<3
      new_pxs[i+k] = clamp(noise + new_pxs[i+k])
      k=k+1
  new_ctx.putImageData(new_imgd,0,0)
  nb(cb, new_c)

#Canip.vignette = (canvas, white, black, callback)
# white and black are between 0 and 1
Canio.vignette = (c, p...) ->
  [cb, white, black]=fff(p, 0.2,0.8)
  [new_c, new_ctx, new_imgd, new_pxs]=getToolbox(copy(c))
  outerRadius = Math.sqrt( Math.pow(new_c.width/2, 2) + Math.pow(new_c.height/2, 2) )
  new_ctx.globalCompositeOperation = 'source-over';
  gradient = new_ctx.createRadialGradient(new_c.width/2, new_c.height/2, 0, new_c.width/2, new_c.height/2, outerRadius);
  gradient.addColorStop(0, 'rgba(0,0,0,0)');
  gradient.addColorStop(0.65, 'rgba(0,0,0,0)');
  gradient.addColorStop(1, 'rgba(0,0,0,' + black + ')');
  new_ctx.fillStyle = gradient;
  new_ctx.fillRect(0, 0, new_c.width, new_c.height);

  new_ctx.globalCompositeOperation = 'lighter';
  gradient = new_ctx.createRadialGradient(new_c.width/2, new_c.height/2, 0, new_c.width/2, new_c.height/2, outerRadius);
  gradient.addColorStop(0, 'rgba(255,255,255,' + white + ')');
  gradient.addColorStop(0.65, 'rgba(255,255,255,0)');
  gradient.addColorStop(1, 'rgba(0,0,0,0)');
  new_ctx.fillStyle = gradient;
  new_ctx.fillRect(0, 0, new_c.width, new_c.height);

  nb(cb,new_c)

#Canio.curves
#Canio.desaturate
# Canio.screen
# Canio.viewfinder
#



Canio.saturate =  (c, p...) ->
  [cb, t]=fff(p, 0.3)
  filter = (r,g,b,a) ->
    average = (r+g+b)/3
    [
      clamp(average + t * (r - average))
      clamp(average + t * (g - average))
      clamp(average + t * (b - average))
      a
    ]
  Canio.rgba(c, cb, filter) #important, callback must be first function

Canio.desaturate = (c, p...) ->
  [cb, t]=fff(p, 0.7)
  Canio.saturate(c,1-t,cb)

Canio.merge = (c, p...) ->
  dlog('inmerge')
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter=(r,g,b,a,i) ->
    red = clamp((r*p_pxs[i])/255)
    green = clamp((g*p_pxs[i+1])/255)
    blue = clamp((b*p_pxs[i+2])/255)
    return [red,green,blue,a]
  Canio.rgba(c, cb, filter)

#just writs one image over the other
#using standard drawing methods
Canio.hardmerge = (c, p...) ->

Canio.negmerge = (c, p...) ->
  dlog('inmerge')
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter=(r,g,b,a,i) ->
    red = clamp((r/p_pxs[i])*255)
    green = clamp((g/p_pxs[i+1])*255)
    blue = clamp((b/p_pxs[i+2])*255)
    return [red,green,blue,a]
  Canio.rgba(c, cb, filter)

Canio.lightmerge = (c, p...) ->
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter = (r,g,b,a,i) ->
    r = (if r > p_pxs[i] then r else p_pxs[i])
    g = (if g > p_pxs[i+1] then g else p_pxs[i+1])
    b = (if b > p_pxs[i+2] then b else p_pxs[i+2])
    return [r,g,b,a]
  Canio.rgba(c, cb, filter)


Canio.darkmerge = (c, p...) ->
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter = (r,g,b,a,i) ->
    r = (if r < p_pxs[i] then r else p_pxs[i])
    g = (if g < p_pxs[i+1] then g else p_pxs[i+1])
    b = (if b < p_pxs[i+2] then b else p_pxs[i+2])
    return [r,g,b,a]
  Canio.rgba(c, cb, filter)

getGrayscaleValue = (r,g,b) -> r*0.3+g*0.59+b*0.11

Canio.lightermerge = (c, p...) ->
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter = (r,g,b,a,i) ->
    lighter = (if getGrayscaleValue(r,g,b)>getGrayscaleValue( p_pxs[i], p_pxs[i+1], p_pxs[i+2]) then true else false)
    r = (if lighter then r else p_pxs[i])
    g = (if lighter then g else p_pxs[i+1])
    b = (if lighter then b else p_pxs[i+2])
    return [r,g,b,a]
  Canio.rgba(c, cb, filter)

Canio.darkermerge = (c, p...) ->
  [cb, picture] = fff(p, null)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  filter = (r,g,b,a,i) ->
    darker = (if getGrayscaleValue(r,g,b)<getGrayscaleValue( p_pxs[i], p_pxs[i+1], p_pxs[i+2]) then true else false)
    r = (if darker then r else p_pxs[i])
    g = (if darker then g else p_pxs[i+1])
    b = (if darker then b else p_pxs[i+2])
    return [r,g,b,a]
  Canio.rgba(c, cb, filter)

Canio.blend = (c, p...) ->
  [cb, picture, amount] = fff(p, null, 0.5)
  until picture then return false
  [p_c, p_ctx, p_imgd, p_pxs]=Canio.getToolbox(Canio.hardResize(picture, c.width, c.height))
  neg_amount = 1 - amount
  filter=(r,g,b,a,i) ->
    #[pr, pg, pb]=[p_pxs[i], p_pxs[i+1], p_pxs[i+2]]
    #alpha
    red = clamp((r*neg_amount)+(p_pxs[i]*amount))
    green = clamp((g*neg_amount)+(p_pxs[i+1]*amount))
    blue = clamp((b*neg_amount)+(p_pxs[i+2]*amount))
    return [red, green, blue, a]
  Canio.rgba(c, cb, filter)


Canio.viewfinder = (c, cb) ->
  cbr(cb, 'Canio.viewfinder')
  pic = new Image()
  pic.onload = () -> Canio.merge(c, pic, cb)
  pic.src = Caniodataurls.viewfinder
  return true

Canio.oldschool = (c, cb) ->
  cbr(cb, 'Canio.oldschool')
  pic = new Image()
  pic.onload = () -> Canio.lightermerge(c, pic, 1, cb)
  pic.src = Caniodataurls.oldschool
  return true

Canio.many = (c, p...) ->
  [cb, actions, params] = fff(p)
  cbr(cb)
  action = actions?.shift() ? null
  paramA = params?.shift() ? []
  until Array.isArray(paramA) then paramA = [paramA]
  if actions.length > 0
    action(c, ((c)->Canio.many(c, cb, actions, params)), paramA...)
  else
    action(c, cb, paramA)








#Canio.heatcam =  (c, p...) ->
#  [cb, t]=fff(p, 0.3)
#  filter = (r,g,b,a) ->
#    average = (r+g+b)/3
#    [
#      # Math.round( ( average - imageData.data[i  ] ) * options.desaturate )
#      clamp(Math.round( ( average - r ) * t ) + average )
#      clamp(Math.round( ( average - g ) * t ) + average )
#      clamp(Math.round( ( average - b ) * t ) + average )
#      a
#    ]
#  Canio.rgba(c, cb, filter)

Canio.nothing = (c, p...) ->
  [cb] = fff(p)
  filter = (r,g,b,a) -> [r,g,b,a]
  Canio.rgba(c,cb,filter)

Canio.curve = (c, p...) ->
  [cb]=fff(p)
  rc = [0, 0, 0, 1, 1, 2, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 7, 7, 7, 7, 8, 8, 8, 9, 9, 9, 9, 10, 10, 10, 10, 11, 11, 12, 12, 12, 12, 13, 13, 13, 14, 14, 15, 15, 16, 16, 17, 17, 17, 18, 19, 19, 20, 21, 22, 22, 23, 24, 25, 26, 27, 28, 29, 30, 31, 32, 33, 34, 35, 36, 37, 39, 40, 41, 42, 44, 45, 47, 48, 49, 52, 54, 55, 57, 59, 60, 62, 65, 67, 69, 70, 72, 74, 77, 79, 81, 83, 86, 88, 90, 92, 94, 97, 99, 101, 103, 107, 109, 111, 112, 116, 118, 120, 124, 126, 127, 129, 133, 135, 136, 140, 142, 143, 145, 149, 150, 152, 155, 157, 159, 162, 163, 165, 167, 170, 171, 173, 176, 177, 178, 180, 183, 184, 185, 188, 189, 190, 192, 194, 195, 196, 198, 200, 201, 202, 203, 204, 206, 207, 208, 209, 211, 212, 213, 214, 215, 216, 218, 219, 219, 220, 221, 222, 223, 224, 225, 226, 227, 227, 228, 229, 229, 230, 231, 232, 232, 233, 234, 234, 235, 236, 236, 237, 238, 238, 239, 239, 240, 241, 241, 242, 242, 243, 244, 244, 245, 245, 245, 246, 247, 247, 248, 248, 249, 249, 249, 250, 251, 251, 252, 252, 252, 253, 254, 254, 254, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255, 255]
  gc = [0, 0, 1, 2, 2, 3, 5, 5, 6, 7, 8, 8, 10, 11, 11, 12, 13, 15, 15, 16, 17, 18, 18, 19, 21, 22, 22, 23, 24, 26, 26, 27, 28, 29, 31, 31, 32, 33, 34, 35, 35, 37, 38, 39, 40, 41, 43, 44, 44, 45, 46, 47, 48, 50, 51, 52, 53, 54, 56, 57, 58, 59, 60, 61, 63, 64, 65, 66, 67, 68, 69, 71, 72, 73, 74, 75, 76, 77, 79, 80, 81, 83, 84, 85, 86, 88, 89, 90, 92, 93, 94, 95, 96, 97, 100, 101, 102, 103, 105, 106, 107, 108, 109, 111, 113, 114, 115, 117, 118, 119, 120, 122, 123, 124, 126, 127, 128, 129, 131, 132, 133, 135, 136, 137, 138, 140, 141, 142, 144, 145, 146, 148, 149, 150, 151, 153, 154, 155, 157, 158, 159, 160, 162, 163, 164, 166, 167, 168, 169, 171, 172, 173, 174, 175, 176, 177, 178, 179, 181, 182, 183, 184, 186, 186, 187, 188, 189, 190, 192, 193, 194, 195, 195, 196, 197, 199, 200, 201, 202, 202, 203, 204, 205, 206, 207, 208, 208, 209, 210, 211, 212, 213, 214, 214, 215, 216, 217, 218, 219, 219, 220, 221, 222, 223, 223, 224, 225, 226, 226, 227, 228, 228, 229, 230, 231, 232, 232, 232, 233, 234, 235, 235, 236, 236, 237, 238, 238, 239, 239, 240, 240, 241, 242, 242, 242, 243, 244, 245, 245, 246, 246, 247, 247, 248, 249, 249, 249, 250, 251, 251, 252, 252, 252, 253, 254, 255]
  bc = [53, 53, 53, 54, 54, 54, 55, 55, 55, 56, 57, 57, 57, 58, 58, 58, 59, 59, 59, 60, 61, 61, 61, 62, 62, 63, 63, 63, 64, 65, 65, 65, 66, 66, 67, 67, 67, 68, 69, 69, 69, 70, 70, 71, 71, 72, 73, 73, 73, 74, 74, 75, 75, 76, 77, 77, 78, 78, 79, 79, 80, 81, 81, 82, 82, 83, 83, 84, 85, 85, 86, 86, 87, 87, 88, 89, 89, 90, 90, 91, 91, 93, 93, 94, 94, 95, 95, 96, 97, 98, 98, 99, 99, 100, 101, 102, 102, 103, 104, 105, 105, 106, 106, 107, 108, 109, 109, 110, 111, 111, 112, 113, 114, 114, 115, 116, 117, 117, 118, 119, 119, 121, 121, 122, 122, 123, 124, 125, 126, 126, 127, 128, 129, 129, 130, 131, 132, 132, 133, 134, 134, 135, 136, 137, 137, 138, 139, 140, 140, 141, 142, 142, 143, 144, 145, 145, 146, 146, 148, 148, 149, 149, 150, 151, 152, 152, 153, 153, 154, 155, 156, 156, 157, 157, 158, 159, 160, 160, 161, 161, 162, 162, 163, 164, 164, 165, 165, 166, 166, 167, 168, 168, 169, 169, 170, 170, 171, 172, 172, 173, 173, 174, 174, 175, 176, 176, 177, 177, 177, 178, 178, 179, 180, 180, 181, 181, 181, 182, 182, 183, 184, 184, 184, 185, 185, 186, 186, 186, 187, 188, 188, 188, 189, 189, 189, 190, 190, 191, 191, 192, 192, 193, 193, 193, 194, 194, 194, 195, 196, 196, 196, 197, 197, 197, 198, 199]
  filter = (r,g,b,a) -> [rc[r],rc[g],rc[b],a]
  Canio.rgba(c,cb,filter)

Canio.screen =  (c, p...) ->
  [cb, rr, gg, bb, strength] = fff(p, 227, 12, 169, 0.2)
  filter = (r,g,b,a) ->
    [
      (255 - ((255 - r) * (255 - rr * strength) / 255))
      (255 - ((255 - g) * (255 - gg * strength) / 255))
      (255 - ((255 - b) * (255 - bb * strength) / 255))
      a
    ]
  Canio.rgba(c,cb,filter)

#PRIVATE IMAGEFILTERS WRAPPER HELPFER

#imagefilters wrapper
ifw = (c, cb, image_filters_func, p...) ->
  [c,ctx,imgd, px] = getToolbox(c)
  [new_c,new_ctx,new_imgd, new_px] = newToolbox(c)
  nb(() -> new_ctx.putImageData(image_filters_func(imgd, p...),0,0))
  nb(cb,new_c)

#make IMAGEFILTERS wrapper
mF = (image_filters_func, defaults...) ->
  return (c, p...) ->
    defaulted_p = fff(p,defaults)
    cb = defaulted_p.shift()
    ifw(c, cb, image_filters_func, defaulted_p...)

#test at http://www.arahaya.com/imagefilters/
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

#ImageFilters.BrightnessContrastGimp (srcImageData, brightness, contrast) #+/- 100
Canio.brightnessConstrastGimp = mF(ImageFilters.BrightnessContrastGimp, 50,50)

#ImageFilters.BrightnessContrastPhotoshop (srcImageData, brightness, contrast)
Canio.brightnessConstrastPhotoshop = mF(ImageFilters.BrightnessContrastPhotoshop, 50,50) #+/- 100

#ImageFilters.Channels (srcImageData, channel) #3 blue, #2 green
Canio.Channels = (channel_string) ->
  if channel_string is "blue" or channel_string is "b"
    channel = 3
  else if channel_string is "green" or channel_string is "g"
    channel = 2
  else
    channel = channel_string
  mF(ImageFilters.Channels, channel)

#NOT #ImageFilters.Clone (srcImageData)
#NOT #ImageFilters.CloneBuiltin (srcImageData)
#NOT - to investiagte #ImageFilters.ColorMatrixFilter (srcImageData, matrix)
#ImageFilters.ColorTransformFilter (srcImageData, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset)
Canio.colorTransform = mF(ImageFilters.ColorTransformFilter, 1, 1, 1, 0, 0, 0) # mutiplyer between 0 and n # offeset between 0 and 255

#NOT #ImageFilters.Copy (srcImageData, dstImageData)
#NOT #ImageFilters.Crop (srcImageData, x, y, width, height)
#NOT #ImageFilters.CropBuiltin (srcImageData, x, y, width, height)
#ImageFilters.Desaturate (srcImageData)
#NOT; lets use a custom iplementation #Canio.desatureate = mF(ImageFilters.Desaturate)

#ImageFilters.DisplacementMapFilter (srcImageData, mapImageData, mapX, mapY, componentX, componentY, scaleX, scaleY, mode)

#ImageFilters.Dither (srcImageData, levels)
Canio.dither = mF(ImageFilters.Dither, 2) #between 1 and 32

#ImageFilters.Edge (srcImageData)
Canio.edge = mF(ImageFilters.Edge)

#ImageFilters.Emboss (srcImageData)
Canio.emboss = mF(ImageFilters.Emboss)

#ImageFilters.Enrich (srcImageData)
Canio.enrich = mF(ImageFilters.Enrich)

#NOT #ImageFilters.Flip (srcImageData, vertical)
#ImageFilters.Gamma (srcImageData, gamma)
Canio.gamma = mF(ImageFilters.Gamma, 2) #between 0 and 3

#ImageFilters.GrayScale (srcImageData)
Canio.grayscale = mF(ImageFilters.Grayscale)

#ImageFilters.HSLAdjustment (srcImageData, hueDelta, satDelta, lightness) #beteen -180 and +180
Canio.HSLAdjustment =mF(ImageFilters.HSLAdjustment, 0, 0, 0)
#ImageFilters.Invert (srcImageData)
Canio.invert = mF(ImageFilters.Invert)
#ImageFilters.Mosaic (srcImageData, blockSize)
Canio.mosaic = mF(ImageFilters.Mosaic, 10)
#ImageFilters.Oil (srcImageData, range, levels)
Canio.oil = mF(ImageFilters.Oil, 4, 30) #range between 1 and 5(?), levels between 1 and 256
#ImageFilters.OpacityFilter (srcImageData, opacity)
Canio.opacity =mF(ImageFilters.OpacityFilter, 10) #?
#ImageFilters.Posterize (srcImageData, levels)
Canio.posterize = mF(ImageFilters.Posterize, 8)

#NOT #ImageFilters.Rescale (srcImageData, scale)
#NOT #ImageFilters.Resize (srcImageData, width, height)
#NOT #ImageFilters.ResizeNearestNeighbor (srcImageData, width, height)
#ImageFilters.Sepia srcImageData)
Canio.sepia = mF(ImageFilters.Sepia)

#ImageFilters.Sharpen (srcImageData, factor)
Canio.sharpen = mF(ImageFilters.Sharpen, 3) #between 1 and n

#ImageFilters.Solarize (srcImageData)
Canio.solarize = mF(ImageFilters.Solarize)
#NOT #ImageFilters.Transpose (srcImageData)
#ImageFilters.Twril (srcImageData, centerX, centerY, radius, angle, edge, smooth)
Canio.twirl = mF(ImageFilters.Twril, 0.5, 0.5, 100, 360) #center between 0 and 1 (ratio to original), radius in peixel, angle # forget edge and smooth
#
#
#todo todo
#http://mezzoblue.github.com/PaintbrushJS/demo/index.html http://github.com/mezzoblue/PaintbrushJS
#http://vintagejs.com/
#https://github.com/alexmic/filtrr
#overview: https://github.com/bebraw/jswiki/wiki/Image-manipulation
#

#export
window.Canio = Canio

