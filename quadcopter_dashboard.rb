require 'fox16'

include Fox

require_relative 'serial_io'
require_relative 'pid_group'
require_relative 'flight_controls_group'

class DashboardWindow < FXMainWindow
  def initialize(app)
    super(app, "Quadcopter Dashboard", width: 1250, height: 600)
    self.padLeft, self.padRight = 10, 10
    self.padTop, self.padBottom = 10, 10
    @arduino = SerialIO.new(app, self, 20)

    @flight_controls = []
    flight_controls_group = FXGroupBox.new(self, "Flight Controls", FRAME_RIDGE)
    flight_controls_group.setFont(FXFont.new(app, "Helvetica", 18,
                                             FONTWEIGHT_BOLD))

    stab_pid_group = FXGroupBox.new(self, "Stab", FRAME_RIDGE)
    stab_pid_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    rate_pid_group = FXGroupBox.new(self, "Rate", FRAME_RIDGE)
    rate_pid_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    [:pitch, :roll, :yaw, :throttle].each.with_index do |control, i|
      @flight_controls[i] = FlightControlsGroup.new(flight_controls_group, self,
                                                    control)
    end

    [:pitch, :roll, :yaw].each do |control|
      PIDGroup.new(stab_pid_group, self, :stab, control)
      PIDGroup.new(rate_pid_group, self, :rate, control)
    end
  end

  def writeout(command, value)
    @arduino.send_output("%s %s" % [command, value])
    STDOUT.puts("%s %s" % [command, value])
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
