require 'fox16'
include Fox

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
