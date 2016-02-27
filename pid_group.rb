class PIDGroup < FXGroupBox
  def initialize(parent, window, name)
    @name = name
    @window = window
    super(parent, @name.to_s.capitalize, FRAME_RIDGE | LAYOUT_SIDE_LEFT)
    self.setFont(FXFont.new(getApp(), "Helvetica", 14, FONTWEIGHT_BOLD))

    # [kp, ki, kd]
    @control = []
    3.times do
      @control << FXDataTarget.new(0.0)
    end

    pid_matrix = FXMatrix.new(self, 3, MATRIX_BY_COLUMNS)

    [:p, :i, :d].each.with_index do |k, i|
      FXLabel.new(pid_matrix, "k#{k}: ")
      FXTextField.new(pid_matrix, 7, @control[i], FXDataTarget::ID_VALUE,
                      TEXTFIELD_READONLY
                     )
      FXRealSpinner.new(pid_matrix, 7, @control[i],
                        FXDataTarget::ID_VALUE, FRAME_NORMAL
                       ).setIncrement(0.01)
      @control[i].connect(SEL_COMMAND) { |sender, sel, data| update_value(k, data) }
    end
  end

  def update_value(k, data)
    @window.update_arduino("%s%s" % [@name[0], k], data)
  end
end
