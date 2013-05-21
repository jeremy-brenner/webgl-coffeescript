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
    for name in @list()
      $( '#' + @picker_id ).append( $('<li>').text(name).on('click', @render_lesson ) )
  render_lesson: (e) =>
    name = $(e.target).text()
    if name in @list()
      new @lessons[name](@canvas_id)
    else 
      console.log "#{name} doesn't exist."

window.web_gl_lessons = new webGLLessons('webgl-canvas','lesson-picker')
