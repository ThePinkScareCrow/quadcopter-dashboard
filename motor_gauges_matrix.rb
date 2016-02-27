class MotorGaugesMatrix < FXMatrix
  def initialize(parent, count, opts)
    super(parent, count, opts)
    @motors = []
    @motor_dials = []

    # order of display is different from the order that the motors are
    # configured in
    [3, 0, 2, 1].each do |i|
      @motors[i] = FXDataTarget.new(0.0)
      @motor_dials[i] = FXDataTarget.new(0)
      FXProgressBar.new(self, @motor_dials[i], FXDataTarget::ID_VALUE,
                        PROGRESSBAR_NORMAL | LAYOUT_FILL |
                        PROGRESSBAR_DIAL | PROGRESSBAR_PERCENTAGE
                       )
      FXTextField.new(self, 7, @motors[i], FXDataTarget::ID_VALUE,
                      TEXTFIELD_READONLY | LAYOUT_CENTER_X | LAYOUT_CENTER_Y
                     )
    end

  end

  def update_values(values)
    values.each.with_index do |value, i|
      @motors[i].value = value
      @motor_dials[i].value = value > 0 ? (value * 100 / 180).to_i : 0
    end
  end
end
