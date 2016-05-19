require 'fox16'

include Fox

require_relative 'serial_io'
require_relative 'pid_group'
require_relative 'flight_controls_group'
require_relative 'control_canvas'
require_relative 'config'

class DashboardWindow < FXMainWindow
  attr_accessor :flight_controls

  def initialize(app)
    super(app, "Quadcopter Dashboard",
          width: Config::WINDOW_WIDTH, height: Config::WINDOW_HEIGHT)
    self.padLeft, self.padRight = 10, 10
    self.padTop, self.padBottom = 10, 10

    begin
      @arduino = SerialIO.new(app, self, 20)
    rescue => e
      puts e
      @arduino = nil
    end

    @flight_controls = { yaw: FXDataTarget.new(0.0),
                         pitch: FXDataTarget.new(0.0),
                         roll: FXDataTarget.new(0.0),
                         throttle: FXDataTarget.new(0.0) }

    flight_controls_group = FXGroupBox.new(self, "Flight Controls", FRAME_RIDGE)
    flight_controls_group.setFont(FXFont.new(app, "Helvetica", 18,
                                             FONTWEIGHT_BOLD))

    stab_pid_group = FXGroupBox.new(self, "Stab", FRAME_RIDGE)
    stab_pid_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    rate_pid_group = FXGroupBox.new(self, "Rate", FRAME_RIDGE)
    rate_pid_group.setFont(FXFont.new(app, "Helvetica", 18, FONTWEIGHT_BOLD))

    @flight_controls.each do |name, target|
      FlightControlsGroup.new(flight_controls_group, self, name, target)
    end

    [:pitch, :roll, :yaw].each do |control|
      PIDGroup.new(stab_pid_group, self, :stab, control)
      PIDGroup.new(rate_pid_group, self, :rate, control)
    end

    ControlCanvas.new(self, self)
  end

  def writeout(command, value)
    @arduino.send_output("%s %s" % [command, value]) if @arduino
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
