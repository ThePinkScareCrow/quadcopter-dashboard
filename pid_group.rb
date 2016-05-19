require_relative 'config'

class PIDGroup < FXGroupBox
  def initialize(parent, window, type, name)
    @name = name
    @window = window
    @type = type
    super(parent, @name.to_s.capitalize, FRAME_RIDGE | LAYOUT_SIDE_LEFT)
    self.setFont(FXFont.new(getApp(), "Helvetica", 14, FONTWEIGHT_BOLD))

    # [kp, ki, kd, kw]
    @control = []
    4.times do
      @control << FXDataTarget.new(0.0)
    end

    pid_matrix = FXMatrix.new(self, 2, MATRIX_BY_COLUMNS)

    [:p, :i, :d, :w].each.with_index do |k, i|
      FXLabel.new(pid_matrix, "k#{k}: ")
      FXRealSpinner.new(pid_matrix, 7, @control[i],
                        FXDataTarget::ID_VALUE, FRAME_NORMAL
                       ).setIncrement(Config::TUNING_STEP)
      @control[i].connect(SEL_COMMAND) { |sender, sel, data| update_value(k, data) }
    end
  end

  #######
  private
  #######

    def update_value(k, data)
      @window.writeout("%s%s%s" % [@type[0], @name[0], k], data)
    end
end
