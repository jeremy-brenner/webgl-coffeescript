class webGLLessons
  constructor: (canvas_id,picker_id) ->
    @canvas_id = canvas_id
    @picker_id = picker_id 
    @lessons = {}

  add: (name,lesson) ->
    @lessons[name] = lesson
    @render_picker()
  list: ->
    _.keys( @lessons )
  render_picker: ->
    $picker = $( '#' + @picker_id )
    $picker.empty()
    for name in @list()
      $picker.append $('<li>').text(name).on('click', @render_lesson ) 
  highlight_lesson: (e) ->
    $(e.target).addClass('selected').siblings().removeClass('selected')
  render_lesson: (e) =>
    @highlight_lesson(e)
    name = $(e.target).text()
    if @current
      @current.stop()
    if name in @list()
      @current = new @lessons[name](@canvas_id)
    else 
      console.log "#{name} doesn't exist."

window.web_gl_lessons = new webGLLessons('webgl-canvas','lesson-picker')
