// Generated by CoffeeScript 1.6.2
(function() {
  var webGLLesson03,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.degToRad = function(degrees) {
    return degrees * Math.PI / 180;
  };

  webGLLesson03 = (function() {
    function webGLLesson03(canvas_id) {
      this.tick = __bind(this.tick, this);      this.canvas = document.getElementById(canvas_id);
      this.initGL();
      this.createMatrices();
      this.initShaders();
      this.initBuffers();
      this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      this.gl.enable(this.gl.DEPTH_TEST);
      this.rTri = 0;
      this.rSquare = 0;
      this.mvMatrixStack = [];
      this.running = true;
      this.tick();
    }

    webGLLesson03.prototype.stop = function() {
      return this.running = false;
    };

    webGLLesson03.prototype.tick = function() {
      if (this.running) {
        requestAnimFrame(this.tick);
        this.drawScene();
        return this.animate();
      }
    };

    webGLLesson03.prototype.shaderFs = "precision mediump float;\n\nvarying vec4 vColor;\n\nvoid main(void) {\n  gl_FragColor = vColor;\n}";

    webGLLesson03.prototype.shaderVs = "attribute vec3 aVertexPosition;\nattribute vec4 aVertexColor;\n\nuniform mat4 uMVMatrix;\nuniform mat4 uPMatrix;\n\nvarying vec4 vColor;\n\nvoid main(void) {\n  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n  vColor = aVertexColor;\n}";

    webGLLesson03.prototype.initGL = function() {
      this.gl = this.canvas.getContext("experimental-webgl");
      this.gl.viewportWidth = this.canvas.width;
      return this.gl.viewportHeight = this.canvas.height;
    };

    webGLLesson03.prototype.createMatrices = function() {
      this.mvMatrix = mat4.create();
      return this.pMatrix = mat4.create();
    };

    webGLLesson03.prototype.initShaders = function() {
      this.fragmentShader = this.getShader(this.gl.FRAGMENT_SHADER, this.shaderFs);
      this.vertexShader = this.getShader(this.gl.VERTEX_SHADER, this.shaderVs);
      this.shaderProgram = this.gl.createProgram();
      this.gl.attachShader(this.shaderProgram, this.vertexShader);
      this.gl.attachShader(this.shaderProgram, this.fragmentShader);
      this.gl.linkProgram(this.shaderProgram);
      if (!this.gl.getProgramParameter(this.shaderProgram, this.gl.LINK_STATUS)) {
        alert("Could not initialise shaders");
      }
      this.gl.useProgram(this.shaderProgram);
      this.shaderProgram.vertexPositionAttribute = this.gl.getAttribLocation(this.shaderProgram, "aVertexPosition");
      this.gl.enableVertexAttribArray(this.shaderProgram.vertexPositionAttribute);
      this.shaderProgram.vertexColorAttribute = this.gl.getAttribLocation(this.shaderProgram, "aVertexColor");
      this.gl.enableVertexAttribArray(this.shaderProgram.vertexColorAttribute);
      this.shaderProgram.pMatrixUniform = this.gl.getUniformLocation(this.shaderProgram, "uPMatrix");
      return this.shaderProgram.mvMatrixUniform = this.gl.getUniformLocation(this.shaderProgram, "uMVMatrix");
    };

    webGLLesson03.prototype.getShader = function(type, code) {
      var shader;

      shader = this.gl.createShader(type);
      this.gl.shaderSource(shader, code);
      this.gl.compileShader(shader);
      if (!this.gl.getShaderParameter(shader, this.gl.COMPILE_STATUS)) {
        alert(this.gl.getShaderInfoLog(shader));
        return null;
      }
      return shader;
    };

    webGLLesson03.prototype.setMatrixUniforms = function() {
      this.gl.uniformMatrix4fv(this.shaderProgram.pMatrixUniform, false, this.pMatrix);
      return this.gl.uniformMatrix4fv(this.shaderProgram.mvMatrixUniform, false, this.mvMatrix);
    };

    webGLLesson03.prototype.initBuffers = function() {
      var colors, i, vertices, _i;

      this.triangleVertexPositionBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);
      vertices = [0.0, 1.0, 0.0, -1.0, -1.0, 0.0, 1.0, -1.0, 0.0];
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(vertices), this.gl.STATIC_DRAW);
      this.triangleVertexPositionBuffer.itemSize = 3;
      this.triangleVertexPositionBuffer.numItems = 3;
      this.triangleVertexColorBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexColorBuffer);
      colors = [1.0, 0.0, 0.0, 1.0, 0.0, 1.0, 0.0, 1.0, 0.0, 0.0, 1.0, 1.0];
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(colors), this.gl.STATIC_DRAW);
      this.triangleVertexColorBuffer.itemSize = 4;
      this.triangleVertexColorBuffer.numItems = 3;
      this.squareVertexPositionBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.squareVertexPositionBuffer);
      vertices = [1.0, 1.0, 0.0, -1.0, 1.0, 0.0, 1.0, -1.0, 0.0, -1.0, -1.0, 0.0];
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(vertices), this.gl.STATIC_DRAW);
      this.squareVertexPositionBuffer.itemSize = 3;
      this.squareVertexPositionBuffer.numItems = 4;
      this.squareVertexColorBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.squareVertexColorBuffer);
      colors = [];
      for (i = _i = 1; _i <= 4; i = ++_i) {
        colors = colors.concat([0.5, 0.5, 1.0, 1.0]);
      }
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(colors), this.gl.STATIC_DRAW);
      this.squareVertexColorBuffer.itemSize = 4;
      return this.squareVertexColorBuffer.numItems = 4;
    };

    webGLLesson03.prototype.drawScene = function() {
      var squareVector, triangleVector;

      this.gl.viewport(0, 0, this.gl.viewportWidth, this.gl.viewportHeight);
      this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
      mat4.perspective(this.pMatrix, 45, this.gl.viewportWidth / this.gl.viewportHeight, 0.1, 100.0);
      mat4.identity(this.mvMatrix);
      triangleVector = vec3.create();
      vec3.set(triangleVector, -1.5, 0.0, -7.0);
      mat4.translate(this.mvMatrix, this.mvMatrix, triangleVector);
      this.mvPushMatrix();
      mat4.rotate(this.mvMatrix, this.mvMatrix, degToRad(this.rTri), [0, 1, 0]);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexPositionBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexPositionAttribute, this.triangleVertexPositionBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.triangleVertexColorBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexColorAttribute, this.triangleVertexColorBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.setMatrixUniforms();
      this.gl.drawArrays(this.gl.TRIANGLES, 0, this.triangleVertexPositionBuffer.numItems);
      this.mvPopMatrix();
      squareVector = vec3.create();
      vec3.set(squareVector, 3.0, 0.0, 0.0);
      mat4.translate(this.mvMatrix, this.mvMatrix, squareVector);
      this.mvPushMatrix();
      mat4.rotate(this.mvMatrix, this.mvMatrix, degToRad(this.rSquare), [1, 0, 0]);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.squareVertexPositionBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexPositionAttribute, this.squareVertexPositionBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.squareVertexColorBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexColorAttribute, this.squareVertexColorBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.setMatrixUniforms();
      this.gl.drawArrays(this.gl.TRIANGLE_STRIP, 0, this.squareVertexPositionBuffer.numItems);
      return this.mvPopMatrix();
    };

    webGLLesson03.prototype.animate = function() {
      var elapsed, timeNow;

      timeNow = new Date().getTime();
      if (this.lastTime) {
        elapsed = timeNow - this.lastTime;
        this.rTri += (90 * elapsed) / 1000.0;
        this.rSquare += (75 * elapsed) / 1000.0;
      }
      return this.lastTime = timeNow;
    };

    webGLLesson03.prototype.mvPushMatrix = function() {
      var copy;

      copy = mat4.create();
      mat4.copy(copy, this.mvMatrix);
      return this.mvMatrixStack.push(copy);
    };

    webGLLesson03.prototype.mvPopMatrix = function() {
      if (this.mvMatrixStack.length === 0) {
        throw "Invalid popMatrix!";
      }
      return this.mvMatrix = this.mvMatrixStack.pop();
    };

    return webGLLesson03;

  })();

  jQuery(function() {
    return web_gl_lessons.add("Lesson03", webGLLesson03);
  });

}).call(this);