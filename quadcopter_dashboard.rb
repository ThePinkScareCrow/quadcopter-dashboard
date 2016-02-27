require 'fox16'

include Fox

require_relative 'serial_io'
require_relative 'pid_group'
require_relative 'flight_controls_group'

class DashboardWindow < FXMainWindow
  def initialize(app)
    super(app, "Quadcopter Dashboard", width: 1000, height: 700)

    @arduino = SerialIO.new(app, self, 100)

    motors_matrix = FXMatrix.new(self, 4, MATRIX_BY_COLUMNS)
    @motors = []
    @motor_dials = []
    # order of display is different from the order that the motors are
    # configured in
    [3, 0, 2, 1].each do |i|
      @motors[i] = FXDataTarget.new(0.0)
      @motor_dials[i] = FXDataTarget.new(0)
      FXProgressBar.new(motors_matrix, @motor_dials[i], FXDataTarget::ID_VALUE,
                        PROGRESSBAR_NORMAL | LAYOUT_FILL |
                        PROGRESSBAR_DIAL | PROGRESSBAR_PERCENTAGE
                       )
      FXTextField.new(motors_matrix, 7, @motors[i], FXDataTarget::ID_VALUE,
                      TEXTFIELD_READONLY | LAYOUT_CENTER_X | LAYOUT_CENTER_Y
                     )
    end

    flight_controls_group = FXGroupBox.new(self, "Flight Controls", FRAME_RIDGE)
    flight_controls_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    flight_control = []
    flight_control[0] = FlightControlsGroup.new(flight_controls_group, self, :pitch)
    flight_control[1] = FlightControlsGroup.new(flight_controls_group, self, :roll)
    flight_control[2] = FlightControlsGroup.new(flight_controls_group, self, :yaw)

    pid_main_group = FXGroupBox.new(self, "PID", FRAME_RIDGE)
    pid_main_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))


    PIDGroup.new(pid_main_group, self, :pitch)
    PIDGroup.new(pid_main_group, self, :roll)
    PIDGroup.new(pid_main_group, self, :yaw)
  end

  def update_values(angles_actual, angles_desired, throttle,
                    pitch_pid, roll_pid, yaw_pid, motors)
    motors.each.with_index do |m, i|
      @motors[i].value = m
      @motor_dials[i].value = m > 0 ? (m * 100 / 180).to_i : 0
    end
  end

  def update_arduino(command, value)
    @arduino.send_output("%s %s" % [command, value])
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
