class ControlCanvas < FXCanvas
  def initialize(parent, window)
    @window = window
    super(parent, width: 100, height: 100, opts: LAYOUT_FILL)
    # canvas.fill(FXRGB(255, 255, 255))
    self.connect(SEL_MOUSEWHEEL, method(:throttle_scroll))
    self.connect(SEL_KEYPRESS, method(:throttle_kill))
  end

  #######
  private
  #######

    def throttle_scroll(*, data)
      if data.code == 120       # scroll up
        @window.flight_controls[:throttle].value += 1
        @window.writeout('t', @window.flight_controls[:throttle])
      elsif data.code == -120   # scroll down
        @window.flight_controls[:throttle].value -= 1
        @window.writeout('t', @window.flight_controls[:throttle])
      end
    end

    def throttle_kill(*, data)
      if data.code == 32        # space
        @window.flight_controls[:throttle].value = 0
        @window.writeout('t', @window.flight_controls[:throttle])
      end
    end
end
