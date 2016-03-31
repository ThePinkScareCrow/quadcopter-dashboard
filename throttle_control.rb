class ThrottleControl < FXGroupBox
  def initialize(parent, window)
    @window = window
    @throttle = FXDataTarget.new(0)
    super(parent, "Throttle", FRAME_RIDGE | LAYOUT_SIDE_LEFT | LAYOUT_FILL_Y)
    self.setFont(FXFont.new(getApp(), "Helvetica", 14, 0))

    spinner = FXRealSpinner.new(self, 7, @throttle,
                                FXDataTarget::ID_VALUE, FRAME_NORMAL
                               )
    spinner.setIncrement(5)
    spinner.range = -180..180

    @throttle.connect(SEL_COMMAND) do |sender, sel, data|
      @window.writeout('t', data)
    end
  end
end

