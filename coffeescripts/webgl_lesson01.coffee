
class webGLLesson01
  constructor: (canvas_id) ->
    @canvas = document.getElementById canvas_id

    @initGL()
    @createMatrices()
    @initShaders()
    @initBuffers()

    @gl.clearColor 0.0, 0.0, 0.0, 1.0
    @gl.enable @gl.DEPTH_TEST

    @drawScene()

  shaderFs: ->
    """
      precision mediump float;

      void main(void) {
        gl_FragColor = vec4(1.0, 1.0, 1.0, 1.0);
      }
    """ 
  shaderVs: ->
    """
      attribute vec3 aVertexPosition;

      uniform mat4 uMVMatrix;
      uniform mat4 uPMatrix;

      void main(void) {
          gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);
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

    @fragmentShader = @getShader @gl.FRAGMENT_SHADER, @shaderFs() 
    @vertexShader   = @getShader @gl.VERTEX_SHADER, @shaderVs()

    @shaderProgram = @gl.createProgram()
    @gl.attachShader @shaderProgram, @vertexShader
    @gl.attachShader @shaderProgram, @fragmentShader 
    @gl.linkProgram @shaderProgram

    if not @gl.getProgramParameter @shaderProgram, @gl.LINK_STATUS
      alert "Could not initialise shaders"

    @gl.useProgram @shaderProgram

    @shaderProgram.vertexPositionAttribute = @gl.getAttribLocation @shaderProgram, "aVertexPosition"
    @gl.enableVertexAttribArray @shaderProgram.vertexPositionAttribute

    @shaderProgram.pMatrixUniform = @gl.getUniformLocation @shaderProgram, "uPMatrix"
    @shaderProgram.mvMatrixUniform = @gl.getUniformLocation @shaderProgram, "uMVMatrix"

  getShader: (t,c) ->
    shader = @gl.createShader(t);
    @gl.shaderSource(shader, c);
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

    @gl.bindBuffer @gl.ARRAY_BUFFER, @triangleVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @triangleVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0
    @setMatrixUniforms()

    @gl.drawArrays @gl.TRIANGLES, 0, @triangleVertexPositionBuffer.numItems


    #draw square
    squareVector = vec3.create()
    vec3.set squareVector, 3.0, 0.0, 0.0 
    
    mat4.translate @mvMatrix, @mvMatrix, squareVector

    @gl.bindBuffer @gl.ARRAY_BUFFER, @squareVertexPositionBuffer
    @gl.vertexAttribPointer @shaderProgram.vertexPositionAttribute, @squareVertexPositionBuffer.itemSize, @gl.FLOAT, false, 0, 0

    @setMatrixUniforms()
  
    @gl.drawArrays @gl.TRIANGLE_STRIP, 0, @squareVertexPositionBuffer.numItems


jQuery ->
  web_gl_lessons.add( "Lesson01", webGLLesson01 )
