require 'fox16'
include Fox

class SerialIO
  def initialize(app, frequency)
    # Until I can get my hands on the Arduino
    @fd = File.open('iamnotanarduino', 'r')
    @app = app
    @frequency = frequency

    # app.addInput(@fd, INPUT_READ, method(:handleInput))
    app.addTimeout(@frequency, method(:handleInput))
  end

  def handleInput(*args)
    puts @fd.readline           # blocks until line is read
    # poor man's buffer ensure's reasonably fresh data next time
    @fd.flush
  rescue EOFError               # probably not required for Arduino
  ensure
    @app.addTimeout(@frequency, method(:handleInput))
  end
end

class DashboardWindow < FXMainWindow
  def initialize(app)
    super(app, "Quadcopter Dashboard", width: 1000, height: 700)

    motors_matrix = FXMatrix.new(self, 2, MATRIX_BY_COLUMNS)
    @motors = []
    # order of display is different from the order that the motors are
    # configured in
    [3, 0, 2, 1].each do |i|
      @motors[i] = FXDataTarget.new(0)
      FXProgressBar.new(motors_matrix, @motors[i], FXDataTarget::ID_VALUE,
                        PROGRESSBAR_NORMAL | LAYOUT_FILL |
                        PROGRESSBAR_DIAL | PROGRESSBAR_PERCENTAGE
                       )
    end

    SerialIO.new(app, 100)
  end

  def create
    super
    show(PLACEMENT_SCREEN)
  end
end

if __FILE__ == $0
  FXApp.new do |app|
    DashboardWindow.new(app)
    app.create
    app.run
  end
end
