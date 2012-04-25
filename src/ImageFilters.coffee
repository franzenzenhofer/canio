# FORK of https://github.com/arahaya/ImageFilters.js
# MIT License
ImageFilters = {}
ImageFilters.utils =
  initSampleCanvas: ->
    _canvas = document.createElement("canvas")
    _context = _canvas.getContext("2d")
    _canvas.width = 0
    _canvas.height = 0
    @getSampleCanvas = ->
      _canvas

    @getSampleContext = ->
      _context

    @createImageData = (if (_context.createImageData) then (w, h) ->
      _context.createImageData w, h
     else (w, h) ->
      new ImageData(w, h)
    )

  getSampleCanvas: ->
    @initSampleCanvas()
    @getSampleCanvas()

  getSampleContext: ->
    @initSampleCanvas()
    @getSampleContext()

  createImageData: (w, h) ->
    @initSampleCanvas()
    @createImageData w, h

  clamp: (value) ->
    (if value > 255 then 255 else (if value < 0 then 0 else value))

  buildMap: (f) ->
    m = []
    k = 0
    v = undefined

    while k < 256
      m[k] = (if (v = f(k)) > 255 then 255 else (if v < 0 then 0 else v | 0))
      k += 1
    m

  applyMap: (src, dst, map) ->
    i = 0
    l = src.length

    while i < l
      dst[i] = map[src[i]]
      dst[i + 1] = map[src[i + 1]]
      dst[i + 2] = map[src[i + 2]]
      dst[i + 3] = src[i + 3]
      i += 4

  mapRGB: (src, dst, func) ->
    @applyMap src, dst, @buildMap(func)

  getPixelIndex: (x, y, width, height, edge) ->
    if x < 0 or x >= width or y < 0 or y >= height
      switch edge
        when 1
          x = (if x < 0 then 0 else (if x >= width then width - 1 else x))
          y = (if y < 0 then 0 else (if y >= height then height - 1 else y))
        when 2
          x = (if (x %= width) < 0 then x + width else x)
          y = (if (y %= height) < 0 then y + height else y)
        else
          return null
    (y * width + x) << 2

  getPixel: (src, x, y, width, height, edge) ->
    if x < 0 or x >= width or y < 0 or y >= height
      switch edge
        when 1
          x = (if x < 0 then 0 else (if x >= width then width - 1 else x))
          y = (if y < 0 then 0 else (if y >= height then height - 1 else y))
        when 2
          x = (if (x %= width) < 0 then x + width else x)
          y = (if (y %= height) < 0 then y + height else y)
        else
          return 0
    i = (y * width + x) << 2
    src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]

  getPixelByIndex: (src, i) ->
    src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]

  copyBilinear: (src, x, y, width, height, dst, dstIndex, edge) ->
    fx = (if x < 0 then x - 1 | 0 else x | 0)
    fy = (if y < 0 then y - 1 | 0 else y | 0)
    wx = x - fx
    wy = y - fy
    i = undefined
    nw = 0
    ne = 0
    sw = 0
    se = 0
    cx = undefined
    cy = undefined
    r = undefined
    g = undefined
    b = undefined
    a = undefined
    if fx >= 0 and fx < (width - 1) and fy >= 0 and fy < (height - 1)
      i = (fy * width + fx) << 2
      if wx or wy
        nw = src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]
        i += 4
        ne = src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]
        i = (i - 8) + (width << 2)
        sw = src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]
        i += 4
        se = src[i + 3] << 24 | src[i] << 16 | src[i + 1] << 8 | src[i + 2]
      else
        dst[dstIndex] = src[i]
        dst[dstIndex + 1] = src[i + 1]
        dst[dstIndex + 2] = src[i + 2]
        dst[dstIndex + 3] = src[i + 3]
        return
    else
      nw = @getPixel(src, fx, fy, width, height, edge)
      if wx or wy
        ne = @getPixel(src, fx + 1, fy, width, height, edge)
        sw = @getPixel(src, fx, fy + 1, width, height, edge)
        se = @getPixel(src, fx + 1, fy + 1, width, height, edge)
      else
        dst[dstIndex] = nw >> 16 & 0xFF
        dst[dstIndex + 1] = nw >> 8 & 0xFF
        dst[dstIndex + 2] = nw & 0xFF
        dst[dstIndex + 3] = nw >> 24 & 0xFF
        return
    cx = 1 - wx
    cy = 1 - wy
    r = ((nw >> 16 & 0xFF) * cx + (ne >> 16 & 0xFF) * wx) * cy + ((sw >> 16 & 0xFF) * cx + (se >> 16 & 0xFF) * wx) * wy
    g = ((nw >> 8 & 0xFF) * cx + (ne >> 8 & 0xFF) * wx) * cy + ((sw >> 8 & 0xFF) * cx + (se >> 8 & 0xFF) * wx) * wy
    b = ((nw & 0xFF) * cx + (ne & 0xFF) * wx) * cy + ((sw & 0xFF) * cx + (se & 0xFF) * wx) * wy
    a = ((nw >> 24 & 0xFF) * cx + (ne >> 24 & 0xFF) * wx) * cy + ((sw >> 24 & 0xFF) * cx + (se >> 24 & 0xFF) * wx) * wy
    dst[dstIndex] = (if r > 255 then 255 else (if r < 0 then 0 else r | 0))
    dst[dstIndex + 1] = (if g > 255 then 255 else (if g < 0 then 0 else g | 0))
    dst[dstIndex + 2] = (if b > 255 then 255 else (if b < 0 then 0 else b | 0))
    dst[dstIndex + 3] = (if a > 255 then 255 else (if a < 0 then 0 else a | 0))

  rgbToHsl: (r, g, b) ->
    r /= 255
    g /= 255
    b /= 255
    max = (if (r > g) then (if (r > b) then r else b) else (if (g > b) then g else b))
    min = (if (r < g) then (if (r < b) then r else b) else (if (g < b) then g else b))
    chroma = max - min
    h = 0
    s = 0
    l = (min + max) / 2
    if chroma isnt 0
      if r is max
        h = (g - b) / chroma + (if (g < b) then 6 else 0)
      else if g is max
        h = (b - r) / chroma + 2
      else
        h = (r - g) / chroma + 4
      h /= 6
      s = (if (l > 0.5) then chroma / (2 - max - min) else chroma / (max + min))
    [ h, s, l ]

  hslToRgb: (h, s, l) ->
    m1 = undefined
    m2 = undefined
    hue = undefined
    r = undefined
    g = undefined
    b = undefined
    rgb = []
    if s is 0
      r = g = b = l * 255 + 0.5 | 0
      rgb = [ r, g, b ]
    else
      if l <= 0.5
        m2 = l * (s + 1)
      else
        m2 = l + s - l * s
      m1 = l * 2 - m2
      hue = h + 1 / 3
      tmp = undefined
      i = 0

      while i < 3
        if hue < 0
          hue += 1
        else hue -= 1  if hue > 1
        if 6 * hue < 1
          tmp = m1 + (m2 - m1) * hue * 6
        else if 2 * hue < 1
          tmp = m2
        else if 3 * hue < 2
          tmp = m1 + (m2 - m1) * (2 / 3 - hue) * 6
        else
          tmp = m1
        rgb[i] = tmp * 255 + 0.5 | 0
        hue -= 1 / 3
        i += 1
    rgb

ImageFilters.Translate = (srcImageData, x, y, interpolation) ->

ImageFilters.Scale = (srcImageData, scaleX, scaleY, interpolation) ->

ImageFilters.Rotate = (srcImageData, originX, originY, angle, resize, interpolation) ->

ImageFilters.Affine = (srcImageData, matrix, resize, interpolation) ->

ImageFilters.UnsharpMask = (srcImageData, level) ->

ImageFilters.ConvolutionFilter = (srcImageData, matrixX, matrixY, matrix, divisor, bias, preserveAlpha, clamp, color, alpha) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  divisor = divisor or 1
  bias = bias or 0
  (preserveAlpha isnt false) and (preserveAlpha = true)
  (clamp isnt false) and (clamp = true)
  color = color or 0
  alpha = alpha or 0
  index = 0
  rows = matrixX >> 1
  cols = matrixY >> 1
  clampR = color >> 16 & 0xFF
  clampG = color >> 8 & 0xFF
  clampB = color & 0xFF
  clampA = alpha * 0xFF
  y = 0

  while y < srcHeight
    x = 0

    while x < srcWidth
      r = 0
      g = 0
      b = 0
      a = 0
      replace = false
      mIndex = 0
      v = undefined
      row = -rows

      while row <= rows
        rowIndex = y + row
        offset = undefined
        if 0 <= rowIndex and rowIndex < srcHeight
          offset = rowIndex * srcWidth
        else if clamp
          offset = y * srcWidth
        else
          replace = true
        col = -cols

        while col <= cols
          m = matrix[mIndex++]
          if m isnt 0
            colIndex = x + col
            unless 0 <= colIndex and colIndex < srcWidth
              if clamp
                colIndex = x
              else
                replace = true
            if replace
              r += m * clampR
              g += m * clampG
              b += m * clampB
              a += m * clampA
            else
              p = (offset + colIndex) << 2
              r += m * srcPixels[p]
              g += m * srcPixels[p + 1]
              b += m * srcPixels[p + 2]
              a += m * srcPixels[p + 3]
          col += 1
        row += 1
      dstPixels[index] = (if (v = r / divisor + bias) > 255 then 255 else (if v < 0 then 0 else v | 0))
      dstPixels[index + 1] = (if (v = g / divisor + bias) > 255 then 255 else (if v < 0 then 0 else v | 0))
      dstPixels[index + 2] = (if (v = b / divisor + bias) > 255 then 255 else (if v < 0 then 0 else v | 0))
      dstPixels[index + 3] = (if preserveAlpha then srcPixels[index + 3] else (if (v = a / divisor + bias) > 255 then 255 else (if v < 0 then 0 else v | 0)))
      x += 1
      index += 4
    y += 1
  dstImageData

ImageFilters.Binarize = (srcImageData, threshold) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  threshold = 0.5  if isNaN(threshold)
  threshold *= 255
  i = 0

  while i < srcLength
    avg = srcPixels[i] + srcPixels[i + 1] + srcPixels[i + 2] / 3
    dstPixels[i] = dstPixels[i + 1] = dstPixels[i + 2] = (if avg <= threshold then 0 else 255)
    dstPixels[i + 3] = 255
    i += 4
  dstImageData

ImageFilters.BlendAdd = (srcImageData, blendImageData, dx, dy) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  blendPixels = blendImageData.data
  v = undefined
  i = 0

  while i < srcLength
    dstPixels[i] = (if ((v = srcPixels[i] + blendPixels[i]) > 255) then 255 else v)
    dstPixels[i + 1] = (if ((v = srcPixels[i + 1] + blendPixels[i + 1]) > 255) then 255 else v)
    dstPixels[i + 2] = (if ((v = srcPixels[i + 2] + blendPixels[i + 2]) > 255) then 255 else v)
    dstPixels[i + 3] = 255
    i += 4
  dstImageData

ImageFilters.BlendSubtract = (srcImageData, blendImageData, dx, dy) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  blendPixels = blendImageData.data
  v = undefined
  i = 0

  while i < srcLength
    dstPixels[i] = (if ((v = srcPixels[i] - blendPixels[i]) < 0) then 0 else v)
    dstPixels[i + 1] = (if ((v = srcPixels[i + 1] - blendPixels[i + 1]) < 0) then 0 else v)
    dstPixels[i + 2] = (if ((v = srcPixels[i + 2] - blendPixels[i + 2]) < 0) then 0 else v)
    dstPixels[i + 3] = 255
    i += 4
  dstImageData

ImageFilters.BoxBlur = do (->
  blur = (src, dst, width, height, radius) ->
    tableSize = radius * 2 + 1
    radiusPlus1 = radius + 1
    widthMinus1 = width - 1
    r = undefined
    g = undefined
    b = undefined
    a = undefined
    srcIndex = 0
    dstIndex = undefined
    p = undefined
    next = undefined
    prev = undefined
    i = undefined
    l = undefined
    x = undefined
    y = undefined
    nextIndex = undefined
    prevIndex = undefined
    sumTable = []
    i = 0
    l = 256 * tableSize

    while i < l
      sumTable[i] = i / tableSize | 0
      i += 1
    y = 0
    while y < height
      r = g = b = a = 0
      dstIndex = y
      p = srcIndex << 2
      r += radiusPlus1 * src[p]
      g += radiusPlus1 * src[p + 1]
      b += radiusPlus1 * src[p + 2]
      a += radiusPlus1 * src[p + 3]
      i = 1
      while i <= radius
        p = (srcIndex + (if i < width then i else widthMinus1)) << 2
        r += src[p]
        g += src[p + 1]
        b += src[p + 2]
        a += src[p + 3]
        i += 1
      x = 0
      while x < width
        p = dstIndex << 2
        dst[p] = sumTable[r]
        dst[p + 1] = sumTable[g]
        dst[p + 2] = sumTable[b]
        dst[p + 3] = sumTable[a]
        nextIndex = x + radiusPlus1
        nextIndex = widthMinus1  if nextIndex > widthMinus1
        prevIndex = x - radius
        prevIndex = 0  if prevIndex < 0
        next = (srcIndex + nextIndex) << 2
        prev = (srcIndex + prevIndex) << 2
        r += src[next] - src[prev]
        g += src[next + 1] - src[prev + 1]
        b += src[next + 2] - src[prev + 2]
        a += src[next + 3] - src[prev + 3]
        dstIndex += height
        x += 1
      srcIndex += width
      y += 1

  return (srcImageData, hRadius, vRadius, quality) ->
    srcPixels = srcImageData.data
    srcWidth = srcImageData.width
    srcHeight = srcImageData.height
    srcLength = srcPixels.length
    dstImageData = @utils.createImageData(srcWidth, srcHeight)
    dstPixels = dstImageData.data
    tmpImageData = @utils.createImageData(srcWidth, srcHeight)
    tmpPixels = tmpImageData.data
    i = 0

    while i < quality
      blur (if i then dstPixels else srcPixels), tmpPixels, srcWidth, srcHeight, hRadius
      blur tmpPixels, dstPixels, srcHeight, srcWidth, vRadius
      i += 1
    dstImageData
)

ImageFilters.GaussianBlur = (srcImageData, strength) ->
  size = undefined
  matrix = undefined
  divisor = undefined
  switch strength
    when 2
      size = 5
      matrix = [ 1, 1, 2, 1, 1, 1, 2, 4, 2, 1, 2, 4, 8, 4, 2, 1, 2, 4, 2, 1, 1, 1, 2, 1, 1 ]
      divisor = 52
    when 3
      size = 7
      matrix = [ 1, 1, 2, 2, 2, 1, 1, 1, 2, 2, 4, 2, 2, 1, 2, 2, 4, 8, 4, 2, 2, 2, 4, 8, 16, 8, 4, 2, 2, 2, 4, 8, 4, 2, 2, 1, 2, 2, 4, 2, 2, 1, 1, 1, 2, 2, 2, 1, 1 ]
      divisor = 140
    when 4
      size = 15
      matrix = [ 2, 2, 3, 4, 5, 5, 6, 6, 6, 5, 5, 4, 3, 2, 2, 2, 3, 4, 5, 7, 7, 8, 8, 8, 7, 7, 5, 4, 3, 2, 3, 4, 6, 7, 9, 10, 10, 11, 10, 10, 9, 7, 6, 4, 3, 4, 5, 7, 9, 10, 12, 13, 13, 13, 12, 10, 9, 7, 5, 4, 5, 7, 9, 11, 13, 14, 15, 16, 15, 14, 13, 11, 9, 7, 5, 5, 7, 10, 12, 14, 16, 17, 18, 17, 16, 14, 12, 10, 7, 5, 6, 8, 10, 13, 15, 17, 19, 19, 19, 17, 15, 13, 10, 8, 6, 6, 8, 11, 13, 16, 18, 19, 20, 19, 18, 16, 13, 11, 8, 6, 6, 8, 10, 13, 15, 17, 19, 19, 19, 17, 15, 13, 10, 8, 6, 5, 7, 10, 12, 14, 16, 17, 18, 17, 16, 14, 12, 10, 7, 5, 5, 7, 9, 11, 13, 14, 15, 16, 15, 14, 13, 11, 9, 7, 5, 4, 5, 7, 9, 10, 12, 13, 13, 13, 12, 10, 9, 7, 5, 4, 3, 4, 6, 7, 9, 10, 10, 11, 10, 10, 9, 7, 6, 4, 3, 2, 3, 4, 5, 7, 7, 8, 8, 8, 7, 7, 5, 4, 3, 2, 2, 2, 3, 4, 5, 5, 6, 6, 6, 5, 5, 4, 3, 2, 2 ]
      divisor = 2044
    else
      size = 3
      matrix = [ 1, 2, 1, 2, 4, 2, 1, 2, 1 ]
      divisor = 16
  ImageFilters.ConvolutionFilter srcImageData, size, size, matrix, divisor, 0, false

ImageFilters.StackBlur = do (->
  BlurStack = ->
    @r = 0
    @g = 0
    @b = 0
    @a = 0
    @next = null
  mul_table = [ 512, 512, 456, 512, 328, 456, 335, 512, 405, 328, 271, 456, 388, 335, 292, 512, 454, 405, 364, 328, 298, 271, 496, 456, 420, 388, 360, 335, 312, 292, 273, 512, 482, 454, 428, 405, 383, 364, 345, 328, 312, 298, 284, 271, 259, 496, 475, 456, 437, 420, 404, 388, 374, 360, 347, 335, 323, 312, 302, 292, 282, 273, 265, 512, 497, 482, 468, 454, 441, 428, 417, 405, 394, 383, 373, 364, 354, 345, 337, 328, 320, 312, 305, 298, 291, 284, 278, 271, 265, 259, 507, 496, 485, 475, 465, 456, 446, 437, 428, 420, 412, 404, 396, 388, 381, 374, 367, 360, 354, 347, 341, 335, 329, 323, 318, 312, 307, 302, 297, 292, 287, 282, 278, 273, 269, 265, 261, 512, 505, 497, 489, 482, 475, 468, 461, 454, 447, 441, 435, 428, 422, 417, 411, 405, 399, 394, 389, 383, 378, 373, 368, 364, 359, 354, 350, 345, 341, 337, 332, 328, 324, 320, 316, 312, 309, 305, 301, 298, 294, 291, 287, 284, 281, 278, 274, 271, 268, 265, 262, 259, 257, 507, 501, 496, 491, 485, 480, 475, 470, 465, 460, 456, 451, 446, 442, 437, 433, 428, 424, 420, 416, 412, 408, 404, 400, 396, 392, 388, 385, 381, 377, 374, 370, 367, 363, 360, 357, 354, 350, 347, 344, 341, 338, 335, 332, 329, 326, 323, 320, 318, 315, 312, 310, 307, 304, 302, 299, 297, 294, 292, 289, 287, 285, 282, 280, 278, 275, 273, 271, 269, 267, 265, 263, 261, 259 ]
  shg_table = [ 9, 11, 12, 13, 13, 14, 14, 15, 15, 15, 15, 16, 16, 16, 16, 17, 17, 17, 17, 17, 17, 17, 18, 18, 18, 18, 18, 18, 18, 18, 18, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 19, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 20, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 21, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 22, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 23, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24 ]
  return (srcImageData, radius) ->
    srcPixels = srcImageData.data
    srcWidth = srcImageData.width
    srcHeight = srcImageData.height
    srcLength = srcPixels.length
    dstImageData = @Clone(srcImageData)
    dstPixels = dstImageData.data
    x = undefined
    y = undefined
    i = undefined
    p = undefined
    yp = undefined
    yi = undefined
    yw = undefined
    r_sum = undefined
    g_sum = undefined
    b_sum = undefined
    a_sum = undefined
    r_out_sum = undefined
    g_out_sum = undefined
    b_out_sum = undefined
    a_out_sum = undefined
    r_in_sum = undefined
    g_in_sum = undefined
    b_in_sum = undefined
    a_in_sum = undefined
    pr = undefined
    pg = undefined
    pb = undefined
    pa = undefined
    rbs = undefined
    div = radius + radius + 1
    w4 = srcWidth << 2
    widthMinus1 = srcWidth - 1
    heightMinus1 = srcHeight - 1
    radiusPlus1 = radius + 1
    sumFactor = radiusPlus1 * (radiusPlus1 + 1) / 2
    stackStart = new BlurStack()
    stack = stackStart
    stackIn = undefined
    stackOut = undefined
    stackEnd = undefined
    mul_sum = mul_table[radius]
    shg_sum = shg_table[radius]
    i = 1
    while i < div
      stack = stack.next = new BlurStack()
      stackEnd = stack  if i is radiusPlus1
      i += 1
    stack.next = stackStart
    yw = yi = 0
    y = 0
    while y < srcHeight
      r_in_sum = g_in_sum = b_in_sum = a_in_sum = r_sum = g_sum = b_sum = a_sum = 0
      r_out_sum = radiusPlus1 * (pr = dstPixels[yi])
      g_out_sum = radiusPlus1 * (pg = dstPixels[yi + 1])
      b_out_sum = radiusPlus1 * (pb = dstPixels[yi + 2])
      a_out_sum = radiusPlus1 * (pa = dstPixels[yi + 3])
      r_sum += sumFactor * pr
      g_sum += sumFactor * pg
      b_sum += sumFactor * pb
      a_sum += sumFactor * pa
      stack = stackStart
      i = 0
      while i < radiusPlus1
        stack.r = pr
        stack.g = pg
        stack.b = pb
        stack.a = pa
        stack = stack.next
        i += 1
      i = 1
      while i < radiusPlus1
        p = yi + ((if widthMinus1 < i then widthMinus1 else i) << 2)
        r_sum += (stack.r = (pr = dstPixels[p])) * (rbs = radiusPlus1 - i)
        g_sum += (stack.g = (pg = dstPixels[p + 1])) * rbs
        b_sum += (stack.b = (pb = dstPixels[p + 2])) * rbs
        a_sum += (stack.a = (pa = dstPixels[p + 3])) * rbs
        r_in_sum += pr
        g_in_sum += pg
        b_in_sum += pb
        a_in_sum += pa
        stack = stack.next
        i += 1
      stackIn = stackStart
      stackOut = stackEnd
      x = 0
      while x < srcWidth
        dstPixels[yi] = (r_sum * mul_sum) >> shg_sum
        dstPixels[yi + 1] = (g_sum * mul_sum) >> shg_sum
        dstPixels[yi + 2] = (b_sum * mul_sum) >> shg_sum
        dstPixels[yi + 3] = (a_sum * mul_sum) >> shg_sum
        r_sum -= r_out_sum
        g_sum -= g_out_sum
        b_sum -= b_out_sum
        a_sum -= a_out_sum
        r_out_sum -= stackIn.r
        g_out_sum -= stackIn.g
        b_out_sum -= stackIn.b
        a_out_sum -= stackIn.a
        p = (yw + (if (p = x + radius + 1) < widthMinus1 then p else widthMinus1)) << 2
        r_in_sum += (stackIn.r = dstPixels[p])
        g_in_sum += (stackIn.g = dstPixels[p + 1])
        b_in_sum += (stackIn.b = dstPixels[p + 2])
        a_in_sum += (stackIn.a = dstPixels[p + 3])
        r_sum += r_in_sum
        g_sum += g_in_sum
        b_sum += b_in_sum
        a_sum += a_in_sum
        stackIn = stackIn.next
        r_out_sum += (pr = stackOut.r)
        g_out_sum += (pg = stackOut.g)
        b_out_sum += (pb = stackOut.b)
        a_out_sum += (pa = stackOut.a)
        r_in_sum -= pr
        g_in_sum -= pg
        b_in_sum -= pb
        a_in_sum -= pa
        stackOut = stackOut.next
        yi += 4
        x += 1
      yw += srcWidth
      y += 1
    x = 0
    while x < srcWidth
      g_in_sum = b_in_sum = a_in_sum = r_in_sum = g_sum = b_sum = a_sum = r_sum = 0
      yi = x << 2
      r_out_sum = radiusPlus1 * (pr = dstPixels[yi])
      g_out_sum = radiusPlus1 * (pg = dstPixels[yi + 1])
      b_out_sum = radiusPlus1 * (pb = dstPixels[yi + 2])
      a_out_sum = radiusPlus1 * (pa = dstPixels[yi + 3])
      r_sum += sumFactor * pr
      g_sum += sumFactor * pg
      b_sum += sumFactor * pb
      a_sum += sumFactor * pa
      stack = stackStart
      i = 0
      while i < radiusPlus1
        stack.r = pr
        stack.g = pg
        stack.b = pb
        stack.a = pa
        stack = stack.next
        i += 1
      yp = srcWidth
      i = 1
      while i <= radius
        yi = (yp + x) << 2
        r_sum += (stack.r = (pr = dstPixels[yi])) * (rbs = radiusPlus1 - i)
        g_sum += (stack.g = (pg = dstPixels[yi + 1])) * rbs
        b_sum += (stack.b = (pb = dstPixels[yi + 2])) * rbs
        a_sum += (stack.a = (pa = dstPixels[yi + 3])) * rbs
        r_in_sum += pr
        g_in_sum += pg
        b_in_sum += pb
        a_in_sum += pa
        stack = stack.next
        yp += srcWidth  if i < heightMinus1
        i += 1
      yi = x
      stackIn = stackStart
      stackOut = stackEnd
      y = 0
      while y < srcHeight
        p = yi << 2
        dstPixels[p] = (r_sum * mul_sum) >> shg_sum
        dstPixels[p + 1] = (g_sum * mul_sum) >> shg_sum
        dstPixels[p + 2] = (b_sum * mul_sum) >> shg_sum
        dstPixels[p + 3] = (a_sum * mul_sum) >> shg_sum
        r_sum -= r_out_sum
        g_sum -= g_out_sum
        b_sum -= b_out_sum
        a_sum -= a_out_sum
        r_out_sum -= stackIn.r
        g_out_sum -= stackIn.g
        b_out_sum -= stackIn.b
        a_out_sum -= stackIn.a
        p = (x + ((if (p = y + radiusPlus1) < heightMinus1 then p else heightMinus1) * srcWidth)) << 2
        r_sum += (r_in_sum += (stackIn.r = dstPixels[p]))
        g_sum += (g_in_sum += (stackIn.g = dstPixels[p + 1]))
        b_sum += (b_in_sum += (stackIn.b = dstPixels[p + 2]))
        a_sum += (a_in_sum += (stackIn.a = dstPixels[p + 3]))
        stackIn = stackIn.next
        r_out_sum += (pr = stackOut.r)
        g_out_sum += (pg = stackOut.g)
        b_out_sum += (pb = stackOut.b)
        a_out_sum += (pa = stackOut.a)
        r_in_sum -= pr
        g_in_sum -= pg
        b_in_sum -= pb
        a_in_sum -= pa
        stackOut = stackOut.next
        yi += srcWidth
        y += 1
      x += 1
    dstImageData
)
ImageFilters.Brightness = (srcImageData, brightness) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    value += brightness
    (if (value > 255) then 255 else value)

  dstImageData

ImageFilters.BrightnessContrastGimp = (srcImageData, brightness, contrast) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  p4 = Math.PI / 4
  brightness /= 100
  contrast *= 0.99
  contrast /= 100
  contrast = Math.tan((contrast + 1) * p4)
  avg = 0
  i = 0

  while i < srcLength
    avg += (srcPixels[i] * 19595 + srcPixels[i + 1] * 38470 + srcPixels[i + 2] * 7471) >> 16
    i += 4
  avg = avg / (srcLength / 4)
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    if brightness < 0
      value = value * (1 + brightness)
    else value = value + ((255 - value) * brightness)  if brightness > 0
    value = (value - avg) * contrast + avg  if contrast isnt 0
    value + 0.5 | 0

  dstImageData

ImageFilters.BrightnessContrastPhotoshop = (srcImageData, brightness, contrast) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  brightness = (brightness + 100) / 100
  contrast = (contrast + 100) / 100
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    value *= brightness
    value = (value - 127.5) * contrast + 127.5
    value + 0.5 | 0

  dstImageData

ImageFilters.Channels = (srcImageData, channel) ->
  matrix = undefined
  switch channel
    when 2
      matrix = [ 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 1, 0 ]
    when 3
      matrix = [ 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 1, 0 ]
    else
      matrix = [ 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 1, 0 ]
  @ColorMatrixFilter srcImageData, matrix

ImageFilters.Clone = (srcImageData) ->
  @Copy srcImageData, @utils.createImageData(srcImageData.width, srcImageData.height)

ImageFilters.CloneBuiltin = (srcImageData) ->
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  canvas = @utils.getSampleCanvas()
  context = @utils.getSampleContext()
  dstImageData = undefined
  canvas.width = srcWidth
  canvas.height = srcHeight
  context.putImageData srcImageData, 0, 0
  dstImageData = context.getImageData(0, 0, srcWidth, srcHeight)
  canvas.width = 0
  canvas.height = 0
  dstImageData

ImageFilters.ColorMatrixFilter = (srcImageData, matrix) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  m0 = matrix[0]
  m1 = matrix[1]
  m2 = matrix[2]
  m3 = matrix[3]
  m4 = matrix[4]
  m5 = matrix[5]
  m6 = matrix[6]
  m7 = matrix[7]
  m8 = matrix[8]
  m9 = matrix[9]
  m10 = matrix[10]
  m11 = matrix[11]
  m12 = matrix[12]
  m13 = matrix[13]
  m14 = matrix[14]
  m15 = matrix[15]
  m16 = matrix[16]
  m17 = matrix[17]
  m18 = matrix[18]
  m19 = matrix[19]
  value = undefined
  i = undefined
  r = undefined
  g = undefined
  b = undefined
  a = undefined
  i = 0
  while i < srcLength
    r = srcPixels[i]
    g = srcPixels[i + 1]
    b = srcPixels[i + 2]
    a = srcPixels[i + 3]
    dstPixels[i] = (if (value = r * m0 + g * m1 + b * m2 + a * m3 + m4) > 255 then 255 else (if value < 0 then 0 else value | 0))
    dstPixels[i + 1] = (if (value = r * m5 + g * m6 + b * m7 + a * m8 + m9) > 255 then 255 else (if value < 0 then 0 else value | 0))
    dstPixels[i + 2] = (if (value = r * m10 + g * m11 + b * m12 + a * m13 + m14) > 255 then 255 else (if value < 0 then 0 else value | 0))
    dstPixels[i + 3] = (if (value = r * m15 + g * m16 + b * m17 + a * m18 + m19) > 255 then 255 else (if value < 0 then 0 else value | 0))
    i += 4
  dstImageData

ImageFilters.ColorTransformFilter = (srcImageData, redMultiplier, greenMultiplier, blueMultiplier, alphaMultiplier, redOffset, greenOffset, blueOffset, alphaOffset) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  i = undefined
  v = undefined
  i = 0
  while i < srcLength
    dstPixels[i] = (if (v = srcPixels[i] * redMultiplier + redOffset) > 255 then 255 else (if v < 0 then 0 else v))
    dstPixels[i + 1] = (if (v = srcPixels[i + 1] * greenMultiplier + greenOffset) > 255 then 255 else (if v < 0 then 0 else v))
    dstPixels[i + 2] = (if (v = srcPixels[i + 2] * blueMultiplier + blueOffset) > 255 then 255 else (if v < 0 then 0 else v))
    dstPixels[i + 3] = (if (v = srcPixels[i + 3] * alphaMultiplier + alphaOffset) > 255 then 255 else (if v < 0 then 0 else v))
    i += 4
  dstImageData

ImageFilters.Copy = (srcImageData, dstImageData) ->
  srcPixels = srcImageData.data
  srcLength = srcPixels.length
  dstPixels = dstImageData.data
  dstPixels[srcLength] = srcPixels[srcLength]  while srcLength--
  dstImageData

ImageFilters.Crop = (srcImageData, x, y, width, height) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(width, height)
  dstPixels = dstImageData.data
  srcLeft = Math.max(x, 0)
  srcTop = Math.max(y, 0)
  srcRight = Math.min(x + width, srcWidth)
  srcBottom = Math.min(y + height, srcHeight)
  dstLeft = srcLeft - x
  dstTop = srcTop - y
  srcRow = undefined
  srcCol = undefined
  srcIndex = undefined
  dstIndex = undefined
  srcRow = srcTop
  dstRow = dstTop

  while srcRow < srcBottom
    srcCol = srcLeft
    dstCol = dstLeft

    while srcCol < srcRight
      srcIndex = (srcRow * srcWidth + srcCol) << 2
      dstIndex = (dstRow * width + dstCol) << 2
      dstPixels[dstIndex] = srcPixels[srcIndex]
      dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
      dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
      dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      srcCol += 1
      dstCol += 1
    srcRow += 1
    dstRow += 1
  dstImageData

ImageFilters.CropBuiltin = (srcImageData, x, y, width, height) ->
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  canvas = @utils.getSampleCanvas()
  context = @utils.getSampleContext()
  canvas.width = srcWidth
  canvas.height = srcHeight
  context.putImageData srcImageData, 0, 0
  result = context.getImageData(x, y, width, height)
  canvas.width = 0
  canvas.height = 0
  result

ImageFilters.Desaturate = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  i = 0

  while i < srcLength
    r = srcPixels[i]
    g = srcPixels[i + 1]
    b = srcPixels[i + 2]
    max = (if (r > g) then (if (r > b) then r else b) else (if (g > b) then g else b))
    min = (if (r < g) then (if (r < b) then r else b) else (if (g < b) then g else b))
    avg = ((max + min) / 2) + 0.5 | 0
    dstPixels[i] = dstPixels[i + 1] = dstPixels[i + 2] = avg
    dstPixels[i + 3] = srcPixels[i + 3]
    i += 4
  dstImageData

ImageFilters.DisplacementMapFilter = (srcImageData, mapImageData, mapX, mapY, componentX, componentY, scaleX, scaleY, mode) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = ImageFilters.Clone(srcImageData)
  dstPixels = dstImageData.data
  mapX or (mapX = 0)
  mapY or (mapY = 0)
  componentX or (componentX = 0)
  componentY or (componentY = 0)
  scaleX or (scaleX = 0)
  scaleY or (scaleY = 0)
  mode or (mode = 2)
  mapWidth = mapImageData.width
  mapHeight = mapImageData.height
  mapPixels = mapImageData.data
  mapRight = mapWidth + mapX
  mapBottom = mapHeight + mapY
  dstIndex = undefined
  srcIndex = undefined
  mapIndex = undefined
  cx = undefined
  cy = undefined
  tx = undefined
  ty = undefined
  x = undefined
  y = undefined
  x = 0
  while x < srcWidth
    y = 0
    while y < srcHeight
      dstIndex = (y * srcWidth + x) << 2
      if x < mapX or y < mapY or x >= mapRight or y >= mapBottom
        srcIndex = dstIndex
      else
        mapIndex = (y - mapY) * mapWidth + (x - mapX) << 2
        cx = mapPixels[mapIndex + componentX]
        tx = x + (((cx - 128) * scaleX) >> 8)
        cy = mapPixels[mapIndex + componentY]
        ty = y + (((cy - 128) * scaleY) >> 8)
        srcIndex = ImageFilters.utils.getPixelIndex(tx + 0.5 | 0, ty + 0.5 | 0, srcWidth, srcHeight, mode)
        srcIndex = dstIndex  if srcIndex is null
      dstPixels[dstIndex] = srcPixels[srcIndex]
      dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
      dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
      dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      y += 1
    x += 1
  dstImageData

ImageFilters.Dither = (srcImageData, levels) ->
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  dstImageData = @Clone(srcImageData)
  dstPixels = dstImageData.data
  levels = (if levels < 2 then 2 else (if levels > 255 then 255 else levels))
  posterize = undefined
  levelMap = []
  levelsMinus1 = levels - 1
  j = 0
  k = 0
  i = undefined
  i = 0
  while i < levels
    levelMap[i] = (255 * i) / levelsMinus1
    i += 1
  posterize = @utils.buildMap((value) ->
    ret = levelMap[j]
    k += levels
    if k > 255
      k -= 255
      j += 1
    ret
  )
  x = undefined
  y = undefined
  index = undefined
  old_r = undefined
  old_g = undefined
  old_b = undefined
  new_r = undefined
  new_g = undefined
  new_b = undefined
  err_r = undefined
  err_g = undefined
  err_b = undefined
  nbr_r = undefined
  nbr_g = undefined
  nbr_b = undefined
  srcWidthMinus1 = srcWidth - 1
  srcHeightMinus1 = srcHeight - 1
  A = 7 / 16
  B = 3 / 16
  C = 5 / 16
  D = 1 / 16
  y = 0
  while y < srcHeight
    x = 0
    while x < srcWidth
      index = (y * srcWidth + x) << 2
      old_r = dstPixels[index]
      old_g = dstPixels[index + 1]
      old_b = dstPixels[index + 2]
      new_r = posterize[old_r]
      new_g = posterize[old_g]
      new_b = posterize[old_b]
      dstPixels[index] = new_r
      dstPixels[index + 1] = new_g
      dstPixels[index + 2] = new_b
      err_r = old_r - new_r
      err_g = old_g - new_g
      err_b = old_b - new_b
      index += 1 << 2
      if x < srcWidthMinus1
        nbr_r = dstPixels[index] + A * err_r
        nbr_g = dstPixels[index + 1] + A * err_g
        nbr_b = dstPixels[index + 2] + A * err_b
        dstPixels[index] = (if nbr_r > 255 then 255 else (if nbr_r < 0 then 0 else nbr_r | 0))
        dstPixels[index + 1] = (if nbr_g > 255 then 255 else (if nbr_g < 0 then 0 else nbr_g | 0))
        dstPixels[index + 2] = (if nbr_b > 255 then 255 else (if nbr_b < 0 then 0 else nbr_b | 0))
      index += (srcWidth - 2) << 2
      if x > 0 and y < srcHeightMinus1
        nbr_r = dstPixels[index] + B * err_r
        nbr_g = dstPixels[index + 1] + B * err_g
        nbr_b = dstPixels[index + 2] + B * err_b
        dstPixels[index] = (if nbr_r > 255 then 255 else (if nbr_r < 0 then 0 else nbr_r | 0))
        dstPixels[index + 1] = (if nbr_g > 255 then 255 else (if nbr_g < 0 then 0 else nbr_g | 0))
        dstPixels[index + 2] = (if nbr_b > 255 then 255 else (if nbr_b < 0 then 0 else nbr_b | 0))
      index += 1 << 2
      if y < srcHeightMinus1
        nbr_r = dstPixels[index] + C * err_r
        nbr_g = dstPixels[index + 1] + C * err_g
        nbr_b = dstPixels[index + 2] + C * err_b
        dstPixels[index] = (if nbr_r > 255 then 255 else (if nbr_r < 0 then 0 else nbr_r | 0))
        dstPixels[index + 1] = (if nbr_g > 255 then 255 else (if nbr_g < 0 then 0 else nbr_g | 0))
        dstPixels[index + 2] = (if nbr_b > 255 then 255 else (if nbr_b < 0 then 0 else nbr_b | 0))
      index += 1 << 2
      if x < srcWidthMinus1 and y < srcHeightMinus1
        nbr_r = dstPixels[index] + D * err_r
        nbr_g = dstPixels[index + 1] + D * err_g
        nbr_b = dstPixels[index + 2] + D * err_b
        dstPixels[index] = (if nbr_r > 255 then 255 else (if nbr_r < 0 then 0 else nbr_r | 0))
        dstPixels[index + 1] = (if nbr_g > 255 then 255 else (if nbr_g < 0 then 0 else nbr_g | 0))
        dstPixels[index + 2] = (if nbr_b > 255 then 255 else (if nbr_b < 0 then 0 else nbr_b | 0))
      x += 1
    y += 1
  dstImageData

ImageFilters.Edge = (srcImageData) ->
  ImageFilters.ConvolutionFilter srcImageData, 3, 3, [ -1, -1, -1, -1, 8, -1, -1, -1, -1 ]

ImageFilters.Emboss = (srcImageData) ->
  ImageFilters.ConvolutionFilter srcImageData, 3, 3, [ -2, -1, 0, -1, 1, 1, 0, 1, 2 ]

ImageFilters.Enrich = (srcImageData) ->
  ImageFilters.ConvolutionFilter srcImageData, 3, 3, [ 0, -2, 0, -2, 20, -2, 0, -2, 0 ], 10, -40

ImageFilters.Flip = (srcImageData, vertical) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  x = undefined
  y = undefined
  srcIndex = undefined
  dstIndex = undefined
  i = undefined
  y = 0
  while y < srcHeight
    x = 0
    while x < srcWidth
      srcIndex = (y * srcWidth + x) << 2
      if vertical
        dstIndex = ((srcHeight - y - 1) * srcWidth + x) << 2
      else
        dstIndex = (y * srcWidth + (srcWidth - x - 1)) << 2
      dstPixels[dstIndex] = srcPixels[srcIndex]
      dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
      dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
      dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      x += 1
    y += 1
  dstImageData

ImageFilters.Gamma = (srcImageData, gamma) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    value = (255 * Math.pow(value / 255, 1 / gamma) + 0.5)
    (if value > 255 then 255 else value + 0.5 | 0)

  dstImageData

ImageFilters.GrayScale = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  i = 0

  while i < srcLength
    intensity = (srcPixels[i] * 19595 + srcPixels[i + 1] * 38470 + srcPixels[i + 2] * 7471) >> 16
    dstPixels[i] = dstPixels[i + 1] = dstPixels[i + 2] = intensity
    dstPixels[i + 3] = srcPixels[i + 3]
    i += 4
  dstImageData

ImageFilters.HSLAdjustment = (srcImageData, hueDelta, satDelta, lightness) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  hueDelta /= 360
  satDelta /= 100
  lightness /= 100
  rgbToHsl = @utils.rgbToHsl
  hslToRgb = @utils.hslToRgb
  h = undefined
  s = undefined
  l = undefined
  hsl = undefined
  rgb = undefined
  i = undefined
  i = 0
  while i < srcLength
    hsl = rgbToHsl(srcPixels[i], srcPixels[i + 1], srcPixels[i + 2])
    h = hsl[0] + hueDelta
    h += 1  while h < 0
    h -= 1  while h > 1
    s = hsl[1] + hsl[1] * satDelta
    if s < 0
      s = 0
    else s = 1  if s > 1
    l = hsl[2]
    if lightness > 0
      l += (1 - l) * lightness
    else l += l * lightness  if lightness < 0
    rgb = hslToRgb(h, s, l)
    dstPixels[i] = rgb[0]
    dstPixels[i + 1] = rgb[1]
    dstPixels[i + 2] = rgb[2]
    dstPixels[i + 3] = srcPixels[i + 3]
    i += 4
  dstImageData

ImageFilters.Invert = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    255 - value

  dstImageData

ImageFilters.Mosaic = (srcImageData, blockSize) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  cols = Math.ceil(srcWidth / blockSize)
  rows = Math.ceil(srcHeight / blockSize)
  row = undefined
  col = undefined
  x_start = undefined
  x_end = undefined
  y_start = undefined
  y_end = undefined
  x = undefined
  y = undefined
  yIndex = undefined
  index = undefined
  size = undefined
  r = undefined
  g = undefined
  b = undefined
  a = undefined
  row = 0
  while row < rows
    y_start = row * blockSize
    y_end = y_start + blockSize
    y_end = srcHeight  if y_end > srcHeight
    col = 0
    while col < cols
      x_start = col * blockSize
      x_end = x_start + blockSize
      x_end = srcWidth  if x_end > srcWidth
      r = g = b = a = 0
      size = (x_end - x_start) * (y_end - y_start)
      y = y_start
      while y < y_end
        yIndex = y * srcWidth
        x = x_start
        while x < x_end
          index = (yIndex + x) << 2
          r += srcPixels[index]
          g += srcPixels[index + 1]
          b += srcPixels[index + 2]
          a += srcPixels[index + 3]
          x += 1
        y += 1
      r = (r / size) + 0.5 | 0
      g = (g / size) + 0.5 | 0
      b = (b / size) + 0.5 | 0
      a = (a / size) + 0.5 | 0
      y = y_start
      while y < y_end
        yIndex = y * srcWidth
        x = x_start
        while x < x_end
          index = (yIndex + x) << 2
          dstPixels[index] = r
          dstPixels[index + 1] = g
          dstPixels[index + 2] = b
          dstPixels[index + 3] = a
          x += 1
        y += 1
      col += 1
    row += 1
  dstImageData

ImageFilters.Oil = (srcImageData, range, levels) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  index = 0
  rh = []
  gh = []
  bh = []
  rt = []
  gt = []
  bt = []
  x = undefined
  y = undefined
  i = undefined
  row = undefined
  col = undefined
  rowIndex = undefined
  colIndex = undefined
  offset = undefined
  srcIndex = undefined
  sr = undefined
  sg = undefined
  sb = undefined
  ri = undefined
  gi = undefined
  bi = undefined
  r = undefined
  g = undefined
  b = undefined
  y = 0
  while y < srcHeight
    x = 0
    while x < srcWidth
      i = 0
      while i < levels
        rh[i] = gh[i] = bh[i] = rt[i] = gt[i] = bt[i] = 0
        i += 1
      row = -range
      while row <= range
        rowIndex = y + row
        continue  if rowIndex < 0 or rowIndex >= srcHeight
        offset = rowIndex * srcWidth
        col = -range
        while col <= range
          colIndex = x + col
          continue  if colIndex < 0 or colIndex >= srcWidth
          srcIndex = (offset + colIndex) << 2
          sr = srcPixels[srcIndex]
          sg = srcPixels[srcIndex + 1]
          sb = srcPixels[srcIndex + 2]
          ri = (sr * levels) >> 8
          gi = (sg * levels) >> 8
          bi = (sb * levels) >> 8
          rt[ri] += sr
          gt[gi] += sg
          bt[bi] += sb
          rh[ri] += 1
          gh[gi] += 1
          bh[bi] += 1
          col += 1
        row += 1
      r = g = b = 0
      i = 1
      while i < levels
        r = i  if rh[i] > rh[r]
        g = i  if gh[i] > gh[g]
        b = i  if bh[i] > bh[b]
        i += 1
      dstPixels[index] = rt[r] / rh[r] | 0
      dstPixels[index + 1] = gt[g] / gh[g] | 0
      dstPixels[index + 2] = bt[b] / bh[b] | 0
      dstPixels[index + 3] = srcPixels[index + 3]
      index += 4
      x += 1
    y += 1
  dstImageData

ImageFilters.OpacityFilter = (srcImageData, opacity) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  i = 0

  while i < srcLength
    dstPixels[i] = srcPixels[i]
    dstPixels[i + 1] = srcPixels[i + 1]
    dstPixels[i + 2] = srcPixels[i + 2]
    dstPixels[i + 3] = opacity
    i += 4
  dstImageData

ImageFilters.Posterize = (srcImageData, levels) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  levels = (if levels < 2 then 2 else (if levels > 255 then 255 else levels))
  levelMap = []
  levelsMinus1 = levels - 1
  j = 0
  k = 0
  i = undefined
  i = 0
  while i < levels
    levelMap[i] = (255 * i) / levelsMinus1
    i += 1
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    ret = levelMap[j]
    k += levels
    if k > 255
      k -= 255
      j += 1
    ret

  dstImageData

ImageFilters.Rescale = (srcImageData, scale) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    value *= scale
    (if (value > 255) then 255 else value + 0.5 | 0)

  dstImageData

ImageFilters.ResizeNearestNeighbor = (srcImageData, width, height) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(width, height)
  dstPixels = dstImageData.data
  xFactor = srcWidth / width
  yFactor = srcHeight / height
  dstIndex = 0
  srcIndex = undefined
  x = undefined
  y = undefined
  offset = undefined
  y = 0
  while y < height
    offset = ((y * yFactor) | 0) * srcWidth
    x = 0
    while x < width
      srcIndex = (offset + x * xFactor) << 2
      dstPixels[dstIndex] = srcPixels[srcIndex]
      dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
      dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
      dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      dstIndex += 4
      x += 1
    y += 1
  dstImageData

ImageFilters.Resize = (srcImageData, width, height) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(width, height)
  dstPixels = dstImageData.data
  xFactor = srcWidth / width
  yFactor = srcHeight / height
  dstIndex = 0
  x = undefined
  y = undefined
  y = 0
  while y < height
    x = 0
    while x < width
      @utils.copyBilinear srcPixels, x * xFactor, y * yFactor, srcWidth, srcHeight, dstPixels, dstIndex, 0
      dstIndex += 4
      x += 1
    y += 1
  dstImageData

ImageFilters.ResizeBuiltin = (srcImageData, width, height) ->
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  canvas = @utils.getSampleCanvas()
  context = @utils.getSampleContext()
  dstImageData = undefined
  canvas.width = Math.max(srcWidth, width)
  canvas.height = Math.max(srcHeight, height)
  context.save()
  context.putImageData srcImageData, 0, 0
  context.scale width / srcWidth, height / srcHeight
  context.drawImage canvas, 0, 0
  dstImageData = context.getImageData(0, 0, width, height)
  context.restore()
  canvas.width = 0
  canvas.height = 0
  dstImageData

ImageFilters.Sepia = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  r = undefined
  g = undefined
  b = undefined
  i = undefined
  value = undefined
  i = 0
  while i < srcLength
    r = srcPixels[i]
    g = srcPixels[i + 1]
    b = srcPixels[i + 2]
    dstPixels[i] = (if (value = r * 0.393 + g * 0.769 + b * 0.189) > 255 then 255 else (if value < 0 then 0 else value + 0.5 | 0))
    dstPixels[i + 1] = (if (value = r * 0.349 + g * 0.686 + b * 0.168) > 255 then 255 else (if value < 0 then 0 else value + 0.5 | 0))
    dstPixels[i + 2] = (if (value = r * 0.272 + g * 0.534 + b * 0.131) > 255 then 255 else (if value < 0 then 0 else value + 0.5 | 0))
    dstPixels[i + 3] = srcPixels[i + 3]
    i += 4
  dstImageData

ImageFilters.Sharpen = (srcImageData, factor) ->
  ImageFilters.ConvolutionFilter srcImageData, 3, 3, [ -factor / 16, -factor / 8, -factor / 16, -factor / 8, factor * 0.75 + 1, -factor / 8, -factor / 16, -factor / 8, -factor / 16 ]

ImageFilters.Solarize = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  @utils.mapRGB srcPixels, dstPixels, (value) ->
    (if value > 127 then (value - 127.5) * 2 else (127.5 - value) * 2)

  dstImageData

ImageFilters.Transpose = (srcImageData) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcHeight, srcWidth)
  dstPixels = dstImageData.data
  srcIndex = undefined
  dstIndex = undefined
  y = 0
  while y < srcHeight
    x = 0
    while x < srcWidth
      srcIndex = (y * srcWidth + x) << 2
      dstIndex = (x * srcHeight + y) << 2
      dstPixels[dstIndex] = srcPixels[srcIndex]
      dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
      dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
      dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      x += 1
    y += 1
  dstImageData

ImageFilters.Twril = (srcImageData, centerX, centerY, radius, angle, edge, smooth) ->
  srcPixels = srcImageData.data
  srcWidth = srcImageData.width
  srcHeight = srcImageData.height
  srcLength = srcPixels.length
  dstImageData = @utils.createImageData(srcWidth, srcHeight)
  dstPixels = dstImageData.data
  centerX = srcWidth * centerX
  centerY = srcHeight * centerY
  angle *= (Math.PI / 180)
  radius2 = radius * radius
  max_y = srcHeight - 1
  max_x = srcWidth - 1
  dstIndex = 0
  x = undefined
  y = undefined
  dx = undefined
  dy = undefined
  distance = undefined
  a = undefined
  tx = undefined
  ty = undefined
  srcIndex = undefined
  pixel = undefined
  i = undefined
  y = 0
  while y < srcHeight
    x = 0
    while x < srcWidth
      dx = x - centerX
      dy = y - centerY
      distance = dx * dx + dy * dy
      if distance > radius2
        dstPixels[dstIndex] = srcPixels[dstIndex]
        dstPixels[dstIndex + 1] = srcPixels[dstIndex + 1]
        dstPixels[dstIndex + 2] = srcPixels[dstIndex + 2]
        dstPixels[dstIndex + 3] = srcPixels[dstIndex + 3]
      else
        distance = Math.sqrt(distance)
        a = Math.atan2(dy, dx) + (angle * (radius - distance)) / radius
        tx = centerX + distance * Math.cos(a)
        ty = centerY + distance * Math.sin(a)
        if smooth
          @utils.copyBilinear srcPixels, tx, ty, srcWidth, srcHeight, dstPixels, dstIndex, edge
        else
          srcIndex = (ty + 0.5 | 0) * srcWidth + (tx + 0.5 | 0) << 2
          dstPixels[dstIndex] = srcPixels[srcIndex]
          dstPixels[dstIndex + 1] = srcPixels[srcIndex + 1]
          dstPixels[dstIndex + 2] = srcPixels[srcIndex + 2]
          dstPixels[dstIndex + 3] = srcPixels[srcIndex + 3]
      dstIndex += 4
      x += 1
    y += 1
  dstImageData

#export
window.ImageFilters = ImageFilters