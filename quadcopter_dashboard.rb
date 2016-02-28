require 'fox16'

include Fox

require_relative 'serial_io'
require_relative 'pid_group'
require_relative 'flight_controls_group'
require_relative 'throttle_control'
require_relative 'motor_gauges_matrix'

class DashboardWindow < FXMainWindow
  def initialize(app)
    super(app, "Quadcopter Dashboard", width: 1250, height: 600)
    self.padLeft, self.padRight = 10, 10
    self.padTop, self.padBottom = 10, 10
    @arduino = SerialIO.new(app, self, 100)

    @motor_gauges_matrix = MotorGaugesMatrix.new(self, 4, MATRIX_BY_COLUMNS)

    @flight_controls = []
    flight_controls_group = FXGroupBox.new(self, "Flight Controls", FRAME_RIDGE)
    flight_controls_group.setFont(FXFont.new(app, "Helvetica", 18,
                                             FONTWEIGHT_BOLD))

    pid_main_group = FXGroupBox.new(self, "PID", FRAME_RIDGE)
    pid_main_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    [:pitch, :roll, :yaw].each.with_index do |control, i|
      @flight_controls[i] = FlightControlsGroup.new(flight_controls_group, self,
                                                    control)
      PIDGroup.new(pid_main_group, self, control)
    end

    ThrottleControl.new(flight_controls_group, self)
  end

  def update_values(angles_actual, angles_desired, throttle,
                    pitch_pid, roll_pid, yaw_pid, motors)
    @motor_gauges_matrix.update_values(motors)
    @flight_controls.each.with_index do |control, i|
      control.update_actual_angle(angles_actual[i])
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
