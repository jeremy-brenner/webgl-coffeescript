// Generated by CoffeeScript 1.6.2
(function() {
  var webGLLesson,
    __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

  window.degToRad = function(degrees) {
    return degrees * Math.PI / 180;
  };

  webGLLesson = (function() {
    function webGLLesson(canvas_id) {
      this.tick = __bind(this.tick, this);      this.canvas = document.getElementById(canvas_id);
      this.textureLocation = "img/lament_configuration.jpg";
      this.initGL();
      this.createMatrices();
      this.initShaders();
      this.initBuffers();
      this.initTexture();
      this.gl.clearColor(0.0, 0.0, 0.0, 1.0);
      this.gl.enable(this.gl.DEPTH_TEST);
      this.rPyramid = 0;
      this.rCube = 0;
      this.mvMatrixStack = [];
      this.running = true;
      this.tick();
    }

    webGLLesson.prototype.stop = function() {
      return this.running = false;
    };

    webGLLesson.prototype.tick = function() {
      if (this.running) {
        requestAnimFrame(this.tick);
        this.drawScene();
        return this.animate();
      }
    };

    webGLLesson.prototype.shaderFs = "precision mediump float;\n\nvarying vec4 vColor;\n\nvoid main(void) {\n  gl_FragColor = vColor;\n}";

    webGLLesson.prototype.shaderVs = "attribute vec3 aVertexPosition;\nattribute vec4 aVertexColor;\n\nuniform mat4 uMVMatrix;\nuniform mat4 uPMatrix;\n\nvarying vec4 vColor;\n\nvoid main(void) {\n  gl_Position = uPMatrix * uMVMatrix * vec4(aVertexPosition, 1.0);\n  vColor = aVertexColor;\n}";

    webGLLesson.prototype.initGL = function() {
      this.gl = this.canvas.getContext("experimental-webgl");
      this.gl.viewportWidth = this.canvas.width;
      return this.gl.viewportHeight = this.canvas.height;
    };

    webGLLesson.prototype.createMatrices = function() {
      this.mvMatrix = mat4.create();
      return this.pMatrix = mat4.create();
    };

    webGLLesson.prototype.initShaders = function() {
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

    webGLLesson.prototype.getShader = function(type, code) {
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

    webGLLesson.prototype.setMatrixUniforms = function() {
      this.gl.uniformMatrix4fv(this.shaderProgram.pMatrixUniform, false, this.pMatrix);
      return this.gl.uniformMatrix4fv(this.shaderProgram.mvMatrixUniform, false, this.mvMatrix);
    };

    webGLLesson.prototype.initBuffers = function() {
      var color, colors, cubeVertexIndices, unpackedColors, vertices, _i, _j, _len;

      this.cubeVertexPositionBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexPositionBuffer);
      vertices = [-1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, 1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, -1.0, 1.0, -1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, -1.0, 1.0, 1.0, -1.0, 1.0, 1.0, 1.0, 1.0, -1.0, 1.0, -1.0, -1.0, -1.0, -1.0, -1.0, 1.0, -1.0, 1.0, 1.0, -1.0, 1.0, -1.0];
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(vertices), this.gl.STATIC_DRAW);
      this.cubeVertexPositionBuffer.itemSize = 3;
      this.cubeVertexPositionBuffer.numItems = 24;
      this.cubeVertexColorBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexColorBuffer);
      colors = [[1.0, 0.0, 0.0, 1.0], [1.0, 1.0, 0.0, 1.0], [0.0, 1.0, 0.0, 1.0], [1.0, 0.5, 0.5, 1.0], [1.0, 0.0, 1.0, 1.0], [0.0, 0.0, 1.0, 1.0]];
      unpackedColors = [];
      for (_i = 0, _len = colors.length; _i < _len; _i++) {
        color = colors[_i];
        for (_j = 1; _j <= 4; _j++) {
          unpackedColors = unpackedColors.concat(color);
        }
      }
      this.gl.bufferData(this.gl.ARRAY_BUFFER, new Float32Array(unpackedColors), this.gl.STATIC_DRAW);
      this.cubeVertexColorBuffer.itemSize = 4;
      this.cubeVertexColorBuffer.numItems = 24;
      this.cubeVertexIndexBuffer = this.gl.createBuffer();
      this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, this.cubeVertexIndexBuffer);
      cubeVertexIndices = [0, 1, 2, 0, 2, 3, 4, 5, 6, 4, 6, 7, 8, 9, 10, 8, 10, 11, 12, 13, 14, 12, 14, 15, 16, 17, 18, 16, 18, 19, 20, 21, 22, 20, 22, 23];
      this.gl.bufferData(this.gl.ELEMENT_ARRAY_BUFFER, new Uint16Array(cubeVertexIndices), this.gl.STATIC_DRAW);
      this.cubeVertexIndexBuffer.itemSize = 1;
      return this.cubeVertexIndexBuffer.numItems = 36;
    };

    webGLLesson.prototype.drawScene = function() {
      var cubeVector;

      this.gl.viewport(0, 0, this.gl.viewportWidth, this.gl.viewportHeight);
      this.gl.clear(this.gl.COLOR_BUFFER_BIT | this.gl.DEPTH_BUFFER_BIT);
      mat4.perspective(this.pMatrix, 45, this.gl.viewportWidth / this.gl.viewportHeight, 0.1, 100.0);
      mat4.identity(this.mvMatrix);
      cubeVector = vec3.create();
      vec3.set(cubeVector, 3.0, 0.0, 0.0);
      mat4.translate(this.mvMatrix, this.mvMatrix, cubeVector);
      this.mvPushMatrix();
      mat4.rotate(this.mvMatrix, this.mvMatrix, degToRad(this.rCube), [1, 1, 1]);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexPositionBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexPositionAttribute, this.cubeVertexPositionBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.gl.bindBuffer(this.gl.ARRAY_BUFFER, this.cubeVertexColorBuffer);
      this.gl.vertexAttribPointer(this.shaderProgram.vertexColorAttribute, this.cubeVertexColorBuffer.itemSize, this.gl.FLOAT, false, 0, 0);
      this.gl.bindBuffer(this.gl.ELEMENT_ARRAY_BUFFER, this.cubeVertexIndexBuffer);
      this.setMatrixUniforms();
      this.gl.drawElements(this.gl.TRIANGLES, this.cubeVertexIndexBuffer.numItems, this.gl.UNSIGNED_SHORT, 0);
      return this.mvPopMatrix();
    };

    webGLLesson.prototype.initTexture = function() {
      var _this = this;

      this.cubeTexture = this.gl.createTexture();
      this.cubeTexture.image = new Image();
      this.cubeTexture.image.onload = function() {
        return _this.handleLoadedTexture();
      };
      return this.cubeTexture.image.src = this.textureLocation;
    };

    webGLLesson.prototype.handleLoadedTexture = function() {
      this.gl.bindTexture(this.gl.TEXTURE_2D, this.cubeTexture);
      this.gl.pixelStorei(this.gl.UNPACK_FLIP_Y_WEBGL, true);
      this.gl.texImage2D(this.gl.TEXTURE_2D, 0, this.gl.RGBA, this.gl.RGBA, this.gl.UNSIGNED_BYTE, this.cubeTexture.image);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MAG_FILTER, this.gl.NEAREST);
      this.gl.texParameteri(this.gl.TEXTURE_2D, this.gl.TEXTURE_MIN_FILTER, this.gl.NEAREST);
      return this.gl.bindTexture(this.gl.TEXTURE_2D, null);
    };

    webGLLesson.prototype.animate = function() {
      var elapsed, timeNow;

      timeNow = new Date().getTime();
      if (this.lastTime) {
        elapsed = timeNow - this.lastTime;
        this.rPyramid += (90 * elapsed) / 1000.0;
        this.rCube -= (75 * elapsed) / 1000.0;
      }
      return this.lastTime = timeNow;
    };

    webGLLesson.prototype.mvPushMatrix = function() {
      var copy;

      copy = mat4.create();
      mat4.copy(copy, this.mvMatrix);
      return this.mvMatrixStack.push(copy);
    };

    webGLLesson.prototype.mvPopMatrix = function() {
      if (this.mvMatrixStack.length === 0) {
        throw "Invalid popMatrix!";
      }
      return this.mvMatrix = this.mvMatrixStack.pop();
    };

    return webGLLesson;

  })();

  jQuery(function() {
    return web_gl_lessons.add("Lesson05", webGLLesson);
  });

}).call(this);
