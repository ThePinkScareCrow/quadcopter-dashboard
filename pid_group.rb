class PIDGroup < FXGroupBox
  def initialize(parent, title)
    super(parent, title, FRAME_RIDGE | LAYOUT_SIDE_LEFT)

    # [value, kp, ki, kd]
    @control = []
    4.times do
      @control << FXDataTarget.new(0.0)
    end

    self.setFont(FXFont.new(getApp(), "Helvetica", 14, FONTWEIGHT_BOLD))
    pid_matrix = FXMatrix.new(self, 2, MATRIX_BY_COLUMNS)
    FXLabel.new(pid_matrix, 'kp: ')
    FXTextField.new(pid_matrix, 7, @control[1],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
    FXLabel.new(pid_matrix, 'ki: ')
    FXTextField.new(pid_matrix, 7, @control[2],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
    FXLabel.new(pid_matrix, 'kd: ')
    FXTextField.new(pid_matrix, 7, @control[3],
                    TEXTFIELD_READONLY | TEXTFIELD_ENTER_ONLY
                   )
  end
end
