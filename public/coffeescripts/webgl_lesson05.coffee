
class webGLLesson
  constructor: (canvas_id) ->
    @canvas = document.getElementById canvas_id
    @textureLocation = "img/lament_configuration.jpg"

    @initGL()
    @createMatrices()
    @initShaders()
    @initBuffers()
    @initTexture()
 
    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    @rPyramid = 0
    @rCube = 0

    @mvMatrixStack = []
    @running = true

    @tick()
  
  stop: ->
    @running = false

  tick: =>
    if @running
      requestAnimFrame @tick 
      @drawScene()
      @animate()

  shaderFs: 
    """
      precision mediump float;

      varying vec4 vColor;

      void main(void) {
        gl_FragColor = vColor;
      }
    """ 
  shaderVs: 
    """
      attribute vec3 aVertexPosition;
      attribute vec4 aVertexColor;

      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      varying vec4 vColor;

      void main(void) {
        gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
        vColor = aVertexColor;
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

    @shaderProgram.vertexColorAttribute = @gl.getAttribLocation @shaderProgram, "aVertexColor"
    @gl.enableVertexAttribArray @shaderProgram.vertexColorAttribute

    @shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"

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

    @cubeVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexColorBuffer
    colors = [
      [1.0, 0.0, 0.0, 1.0],     # Front face
      [1.0, 1.0, 0.0, 1.0],     # Back face
      [0.0, 1.0, 0.0, 1.0],     # Top face
      [1.0, 0.5, 0.5, 1.0],     # Bottom face
      [1.0, 0.0, 1.0, 1.0],     # Right face
      [0.0, 0.0, 1.0, 1.0],     # Left face
    ];

    unpackedColors = [];
    for color in colors
      for [1..4]
        unpackedColors = unpackedColors.concat(color);    
  
    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(unpackedColors), @gl.STATIC_DRAW
    @cubeVertexColorBuffer.itemSize = 4
    @cubeVertexColorBuffer.numItems = 24

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
    vec3.set cubeVector, 3.0, 0.0, 0.0 
    
    mat4.translate @mvMatrix, @mvMatrix, cubeVector

    @mvPushMatrix();
    
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@rCube), [1, 1, 1]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @cubeVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @cubeVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @cubeVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ELEMENT_ARRAY_BUFFER, @cubeVertexIndexBuffer

    @setMatrixUniforms()
  
    @gl.drawElements @gl.TRIANGLES, @cubeVertexIndexBuffer.numItems, @gl.UNSIGNED_SHORT, 0
     
    @mvPopMatrix()

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
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MAG_FILTER, @gl.NEAREST
    @gl.texParameteri @gl.TEXTURE_2D, @gl.TEXTURE_MIN_FILTER, @gl.NEAREST
    @gl.bindTexture @gl.TEXTURE_2D, null

  animate: ->
    timeNow = new Date().getTime()
    if @lastTime
      elapsed = timeNow - @lastTime
      @rPyramid += ( 90 * elapsed) / 1000.0
      @rCube -= ( 75 * elapsed) / 1000.0
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
