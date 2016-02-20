require 'fox16'
include Fox

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

class PIDGroup < FXGroupBox
  def initialize(parent, title)
    super(parent, title, FRAME_RIDGE | LAYOUT_SIDE_LEFT)

    # [value, kp, ki, kd]
    @control = []
    4.times do
      @control << FXDataTarget.new(0.0)
    end

    self.setFont(FXFont.new(getApp(), "Helvetica", 14, FONTWEIGHT_BOLD))
    pid_matrix = FXMatrix.new(self, 2, MATRIX_BY_COLUMNS)
    FXLabel.new(pid_matrix, 'kp: ')
    FXTextField.new(pid_matrix, 7, @control[1],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
    FXLabel.new(pid_matrix, 'ki: ')
    FXTextField.new(pid_matrix, 7, @control[2],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
    FXLabel.new(pid_matrix, 'kd: ')
    FXTextField.new(pid_matrix, 7, @control[3],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
  end
end

class DashboardWindow < FXMainWindow
  def initialize(app)
    super(app, "Quadcopter Dashboard", width: 1000, height: 700)
    SerialIO.new(app, self, 100)

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


    pid_main_group = FXGroupBox.new(self, "PID", FRAME_RIDGE)
    pid_main_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))
    pitch_group = PIDGroup.new(pid_main_group, "Pitch")
    roll_group = PIDGroup.new(pid_main_group, "Roll")
    yaw_group = PIDGroup.new(pid_main_group, "Yaw")
  end

  def update_values(motors)
    motors.each.with_index do |m, i|
      @motors[i].value = (m * 100).to_i
    end
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
