require 'fox16'
include Fox

require_relative 'serial_io'
require_relative 'pid_group'

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


    PIDGroup.new(pid_main_group, "Pitch")
    PIDGroup.new(pid_main_group, "Roll")
    PIDGroup.new(pid_main_group, "Yaw")
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
