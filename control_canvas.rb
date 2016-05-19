class ControlCanvas < FXCanvas
  def initialize(parent, window)
    @window = window
    super(parent, width: 100, height: 100, opts: LAYOUT_FILL)
    # canvas.fill(FXRGB(255, 255, 255))
    self.connect(SEL_MOUSEWHEEL, method(:scroll_handler))
    self.connect(SEL_KEYPRESS, method(:keypress_handler))
    self.connect(SEL_KEYRELEASE, method(:keyrelease_handler))
  end

  #######
  private
  #######

    def scroll_handler(*, data)
      if data.code == 120       # scroll up
        @window.flight_controls[:throttle].value += 1
        @window.writeout('t', @window.flight_controls[:throttle])
      elsif data.code == -120   # scroll down
        @window.flight_controls[:throttle].value -= 1
        @window.writeout('t', @window.flight_controls[:throttle])
      end
    end

    def keypress_handler(*, data)
      case data.code
      when 32                   # space
        update_key = :throttle
        value = 0
      when 87, 119              # w
        update_key = :pitch
        value = -10
      when 83, 115              # s
        update_key = :pitch
        value = 10
      when 65, 97               # a
        update_key = :roll
        value = -10
      when 68, 100              # d
        update_key = :roll
        value = 10
      end

      unless update_key.nil?
        if update_key == :throttle ||
            (@window.flight_controls[update_key].value != value)
          @window.flight_controls[update_key].value = value
          @window.writeout(update_key[0], value)
        end
      end
    end

    def keyrelease_handler(*, data)
      # This handler is called when the key is released or called
      # repeatedly when the key is held down. We only want to reset
      # the value to 0 when the key is actually let
      # go. FXApp#getKeyState() returns true if the key is currently
      # depressed.
      if getApp().getKeyState(data.code)
        return
      end

      # if key has been released, reset corresponding value to 0
      case data.code
      when 87, 119              # w
        update_key = :pitch
      when 83, 115              # s
        update_key = :pitch
      when 65, 97               # a
        update_key = :roll
      when 68, 100              # d
        update_key = :roll
      end

      unless update_key.nil?
        @window.flight_controls[update_key].value = 0
        @window.writeout(update_key[0], 0)
      end
    end
end
