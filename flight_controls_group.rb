class FlightControlsGroup < FXGroupBox
  def initialize(parent, window, control_name)
    @window = window
    @control_name = control_name
    super(parent, @control_name.to_s.capitalize, FRAME_RIDGE | LAYOUT_SIDE_LEFT)
    self.setFont(FXFont.new(getApp(), "Helvetica", 14, 0))

    @control_actual = FXDataTarget.new(0.0)
    @control_desired = FXDataTarget.new(0.0)

    flight_control_matrix = FXMatrix.new(self, 2, MATRIX_BY_COLUMNS)
    FXLabel.new(flight_control_matrix, "Actual")
    FXLabel.new(flight_control_matrix, "Desired")
    FXTextField.new(flight_control_matrix, 7, @control_actual,
                    FXDataTarget::ID_VALUE, TEXTFIELD_READONLY
                   )
    spinner = FXRealSpinner.new(flight_control_matrix, 7, @control_desired,
                      FXDataTarget::ID_VALUE, FRAME_NORMAL
                               )
    spinner.setIncrement(5)
    spinner.range = -180..180

    @control_desired.connect(SEL_COMMAND, method(:update_desired_angle))
  end

  def update_actual_angle(angle)
    @control_actual.value = angle
  end

  #######
  private
  #######

    def update_desired_angle(sender, selector, data)
      @window.update_arduino(@control_name[0], data)
    end
end
