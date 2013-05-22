
window.degToRad = (degrees) ->
  degrees * Math.PI / 180

class webGLLesson03
  constructor: (canvas_id) ->
    @canvas = document.getElementById canvas_id

    @initGL()
    @createMatrices()
    @initShaders()
    @initBuffers()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    @rTri = 0
    @rSquare = 0
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
    #triangle
    @triangleVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer

    vertices = [
      0.0,  1.0,  0.0,
     -1.0, -1.0,  0.0,
      1.0, -1.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW

    @triangleVertexPositionBuffer.itemSize = 3
    @triangleVertexPositionBuffer.numItems = 3

    @triangleVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    colors = [
        1.0, 0.0, 0.0, 1.0,
        0.0, 1.0, 0.0, 1.0,
        0.0, 0.0, 1.0, 1.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW
    @triangleVertexColorBuffer.itemSize = 4
    @triangleVertexColorBuffer.numItems = 3

    #square
    @squareVertexPositionBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexPositionBuffer

    vertices = [
         1.0,  1.0,  0.0,
        -1.0,  1.0,  0.0,
         1.0, -1.0,  0.0,
        -1.0, -1.0,  0.0
    ]

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(vertices), @gl.STATIC_DRAW

    @squareVertexPositionBuffer.itemSize = 3
    @squareVertexPositionBuffer.numItems = 4

    @squareVertexColorBuffer = @gl.createBuffer()
    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexColorBuffer

    colors = []
    for i in [ 1..4 ]
      colors = colors.concat([0.5, 0.5, 1.0, 1.0]);

    @gl.bufferData @gl.ARRAY_BUFFER, new Float32Array(colors), @gl.STATIC_DRAW
    @squareVertexColorBuffer.itemSize = 4
    @squareVertexColorBuffer.numItems = 4

  drawScene: ->

    #scene setup
    @gl.viewport 0, 0, @gl.viewportWidth, @gl.viewportHeight
    @gl.clear @gl.COLOR_BUFFER_BIT | @gl.DEPTH_BUFFER_BIT
    mat4.perspective @pMatrix, 45, @gl.viewportWidth / @gl.viewportHeight, 0.1, 100.0


    mat4.identity @mvMatrix

    #draw triangle
    triangleVector = vec3.create()
    vec3.set triangleVector, -1.5, 0.0, -7.0 

    mat4.translate @mvMatrix, @mvMatrix, triangleVector

    @mvPushMatrix()
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@rTri), [0, 1, 0]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @triangleVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @setMatrixUniforms()

    @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems

    @mvPopMatrix();

    #draw square
    squareVector = vec3.create()
    vec3.set squareVector, 3.0, 0.0, 0.0 
    
    mat4.translate @mvMatrix, @mvMatrix, squareVector

    @mvPushMatrix();
    
    mat4.rotate @mvMatrix, @mvMatrix, degToRad(@rSquare), [1, 0, 0]

    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @squareVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexColorBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexColorAttribute, @squareVertexColorBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @setMatrixUniforms()
  
    @gl.drawArrays @gl.TRIANGLE_STRIP, 0, @squareVertexPositionBuffer.numItems
    
    @mvPopMatrix()

  animate: ->
    timeNow = new Date().getTime()
    if @lastTime
      elapsed = timeNow - @lastTime
      @rTri += ( 90 * elapsed) / 1000.0
      @rSquare += ( 75 * elapsed) / 1000.0
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
  web_gl_lessons.add( "Lesson03", webGLLesson03 )
