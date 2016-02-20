class SerialIO
  def initialize(app, window, frequency)
    # Until I can get my hands on the Arduino
    @fd = File.open('iamnotanarduino', 'r')
    @app = app
    @window = window
    @frequency = frequency

    # app.addInput(@fd, INPUT_READ, method(:handleInput))
    app.addTimeout(@frequency, method(:handle_input))
  end

  def handle_input(*args)
    parse_input(@fd.readline)           # blocks until line is read
    # poor man's buffer ensure's reasonably fresh data next time
    # TODO: check if this is of any use with the Arduino
    @fd.flush
  rescue EOFError               # probably not required for Arduino
  ensure
    @app.addTimeout(@frequency, method(:handle_input))
  end

  def parse_input(s)
    motors = s.split(' ').collect { |i| i.to_f / 180 }
    @window.update_values(motors)
  end
end
