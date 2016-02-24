class PIDGroup < FXGroupBox
  def initialize(parent, title)
    super(parent, title, FRAME_RIDGE | LAYOUT_SIDE_LEFT)
    self.setFont(FXFont.new(getApp(), "Helvetica", 14, FONTWEIGHT_BOLD))

    # [kp, ki, kd]
    @control = []
    3.times do
      @control << FXDataTarget.new(0.0)
    end

    pid_matrix = FXMatrix.new(self, 3, MATRIX_BY_COLUMNS)

    FXLabel.new(pid_matrix, 'kp: ')
    FXTextField.new(pid_matrix, 7, @control[0], FXDataTarget::ID_VALUE,
                    TEXTFIELD_READONLY
                   )
    FXTextField.new(pid_matrix, 7, @control[0], FXDataTarget::ID_VALUE,
                    TEXTFIELD_ENTER_ONLY | TEXTFIELD_REAL | TEXTFIELD_NORMAL
                   )

    FXLabel.new(pid_matrix, 'ki: ')
    FXTextField.new(pid_matrix, 7, @control[1], FXDataTarget::ID_VALUE,
                    TEXTFIELD_READONLY
                   )
    FXTextField.new(pid_matrix, 7, @control[1], FXDataTarget::ID_VALUE,
                    TEXTFIELD_ENTER_ONLY | TEXTFIELD_REAL | TEXTFIELD_NORMAL
                   )

    FXLabel.new(pid_matrix, 'kd: ')
    FXTextField.new(pid_matrix, 7, @control[2], FXDataTarget::ID_VALUE,
                    TEXTFIELD_READONLY
                   )
    FXTextField.new(pid_matrix, 7, @control[2], FXDataTarget::ID_VALUE,
                    TEXTFIELD_ENTER_ONLY | TEXTFIELD_REAL | TEXTFIELD_NORMAL
                   )

    @control[0].connect(SEL_COMMAND, method(:update_value))
    @control[1].connect(SEL_COMMAND, method(:update_value))
    @control[2].connect(SEL_COMMAND, method(:update_value))
  end

  def update_value(*args)

  end
end
