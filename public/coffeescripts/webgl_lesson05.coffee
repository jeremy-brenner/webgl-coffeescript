
class webGLLesson
  constructor: (canvas_id) ->
    @canvas = document.getElementById canvas_id
    @textureLocation = "img/lament_configuration.jpg"
    #@textureLocation = "img/nehe.gif"

    @initGL()
    @createMatrices()
    @initShaders()
    @initBuffers()
    @initTexture()
 
    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    @xRot = 0
    @yRot = 0
    @zRot = 0

    @mvMatrixStack = []

    @running = true
    @ready = false

    @tick()
  
  stop: ->
    @running = false

  tick: =>
    if @running
      requestAnimFrame @tick 
      if @ready 
        @drawScene()
        @animate()

  shaderFs: 
    """
      precision mediump float;

      varying vec2 vTextureCoord;

      uniform sampler2D uSampler;

      void main(void) {
        gl_FragColor = texture2D(uSampler, vec2(vTextureCoord.s, vTextureCoord.t));
      }
    """ 
  shaderVs: 
    """
      attribute vec3 aVertexPosition;
      attribute vec2 aTextureCoord;

      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec2 vTextureCoord;

      void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        vTextureCoord = aTextureCoord;
      }
    """
  initGL: ->
    @gl = @canvas.getContext("experimental-webgl")
    @gl.viewportWidth = @canvas.width
    @gl.viewportHeight = @canvas.height

  createMatrices: ->
    @mvMatrix = mat4.create()
    @pMatrix = mat4.create()

  initShaders: ->

    @fragmentShader = @getShader @gl.FRAGMENT_SHADER, @shaderFs
    @vertexShader   = @getShader @gl.VERTEX_SHADER, @shaderVs

    @shaderProgram = @gl.createProgram()
    @gl.attachShader @shaderProgram, @vertexShader
    @gl.attachShader @shaderProgram, @fragmentShader 
    @gl.linkProgram @shaderProgram

    if not @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS
      alert "Could not initialise shaders"

    @gl.useProgram @shaderProgram

    @shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, "aVertexPosition"
    @gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute


    @shaderProgram.textureCoordAttribute = @gl.getAttribLocation @shaderProgram, "aTextureCoord"
    @gl.enableVertexAttribArray @shaderProgram.textureCoordAttribute

    @shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"
    @shaderProgram.samplerUniform = @gl.getUniformLocation @shaderProgram, "uSampler"

  getShader: (type,code) ->
    shader = @gl.createShader(type);
    @gl.shaderSource(shader, code);
    @gl.compileShader(shader);
    if not @gl.getShaderParameter shader, @gl.COMPILE_STATUS
      alert @gl.getShaderInfoLog(shader)
      return null;
    return shader;

  setMatrixUniforms: ->
    @gl.uniformMatrix4fv @shaderProgram.pMatrixUniform, false, @pMatrix
    @gl.uniformMatrix4fv @shaderProgram.mvMatrixUniform, false, @mvMatrix

  initBuffers: ->
    @cubeVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer
    vertices = [
      # Front face
      -1.0, -1.0,  1.0,
       1.0, -1.0,  1.0,
       1.0,  1.0,  1.0,
      -1.0,  1.0,  1.0,
      # Back face
      -1.0, -1.0, -1.0,
      -1.0,  1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0, -1.0, -1.0,
      # Top face
      -1.0,  1.0, -1.0,
      -1.0,  1.0,  1.0,
       1.0,  1.0,  1.0,
       1.0,  1.0, -1.0,
      # Bottom face
      -1.0, -1.0, -1.0,
       1.0, -1.0, -1.0,
       1.0, -1.0,  1.0,
      -1.0, -1.0,  1.0,
      # Right face
       1.0, -1.0, -1.0,
       1.0,  1.0, -1.0,
       1.0,  1.0,  1.0,
       1.0, -1.0,  1.0,
      # Left face
      -1.0, -1.0, -1.0,
      -1.0, -1.0,  1.0,
      -1.0,  1.0,  1.0,
      -1.0,  1.0, -1.0,
    ]
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW
    @cubeVertexPositionBuffer.itemSize = 3
    @cubeVertexPositionBuffer.numItems = 24

    @cubeVertexTextureCoordBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexTextureCoordBuffer
    @textureCoords = [
      # Front face
      0.012, 0.04,
      0.32, 0.04,
      0.32, 0.345,
      0.012, 0.345,

      # Back face
      0.344, 0.36,
      0.656, 0.36,
      0.656, 0.668,
      0.344, 0.668,

      # Top face
      0.348, 0.686,
      0.656, 0.686,
      0.656, 0.994,
      0.348, 0.994,

      # Bottom face  
      0.012, 0.36,
      0.32, 0.36,
      0.32, 0.668,
      0.012, 0.668,

      # Right faceCURRENT
      0.014, 0.686,
      0.318, 0.686,
      0.318, 0.994,
      0.014, 0.994,

      # Left face
      0.345, 0.037,
      0.654, 0.037,
      0.654, 0.341,
      0.345, 0.341,
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array( @textureCoords ), @gl.STATIC_DRAW
    @cubeVertexTextureCoordBuffer.itemSize = 2;
    @cubeVertexTextureCoordBuffer.numItems = 24;

    @cubeVertexIndexBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer
    cubeVertexIndices = [
      0, 1, 2,      0, 2, 3,    # Front face
      4, 5, 6,      4, 6, 7,    # Back face
      8, 9, 10,     8, 10, 11,  # Top face
      12, 13, 14,   12, 14, 15, # Bottom face
      16, 17, 18,   16, 18, 19, # Right face
      20, 21, 22,   20, 22, 23  # Left face
    ]
    @gl.bufferData @gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), @gl.STATIC_DRAW
    @cubeVertexIndexBuffer.itemSize = 1
    @cubeVertexIndexBuffer.numItems = 36
  drawScene: ->

    #scene setup
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT

    mat4.perspective @pMatrix, 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0

    mat4.identity @mvMatrix

    #draw cube
    cubeVector = vec3.create()

    vec3.set cubeVector, 0.0, 0.0, -3.5 
    
    mat4.translate @mvMatrix, @mvMatrix, cubeVector
    
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@xRot), [1, 0, 0]
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@yRot), [0, 1, 0]
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@zRot), [0, 0, 1]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexTextureCoordBuffer
    @gl.vertexAttribPointer @shaderProgram.textureCoordAttribute, @cubeVertexTextureCoordBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.activeTexture @gl.TEXTURE0
    @gl.bindTexture @gl.TEXTURE_2D, @cubeTexture
    @gl.uniform1i @shaderProgram.samplerUniform, 0

    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer

    @setMatrixUniforms()
  
    @gl.drawElements @gl.TRIANGLES, @cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0
     

  initTexture: ->
    @cubeTexture = @gl.createTexture()
    @cubeTexture.image = new Image()
    @cubeTexture.image.onload = => 
      @handleLoadedTexture()
    
    @cubeTexture.image.src = @textureLocation
  
  handleLoadedTexture: ->
    @gl.bindTexture @gl.TEXTURE_2D, @cubeTexture 
    @gl.pixelStorei @gl.UNPACK_FLIP_Y_WEBGL, true
    @gl.texImage2D @gl.TEXTURE_2D, 0, @gl.RGBA, @gl.RGBA, @gl.UNSIGNED_BYTE, @cubeTexture.image
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.LINEAR
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.LINEAR_MIPMAP_NEAREST
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_WRAP_S, @gl.CLAMP_TO_EDGE
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_WRAP_T, @gl.CLAMP_TO_EDGE
    @gl.generateMipmap @gl.TEXTURE_2D
    @gl.bindTexture @gl.TEXTURE_2D, null
    @ready = true

  animate: ->
    timeNow = new Date().getTime()
    if @lastTime
      elapsed = timeNow - @lastTime
      @xRot += (15 * elapsed) / 1000.0 
      @yRot += (10 * elapsed) / 1000.0 
      @zRot += (20 * elapsed) / 1000.0 
    @lastTime = timeNow

  mvPushMatrix: ->
    copy = mat4.create()
    mat4.copy copy, @mvMatrix
    @mvMatrixStack.push(copy)

  mvPopMatrix: ->
    if @mvMatrixStack.length is 0
      throw "Invalid popMatrix!"
    @mvMatrix = @mvMatrixStack.pop()


jQuery ->
  web_gl_lessons.add( "Lesson05", webGLLesson )
