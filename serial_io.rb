require 'serialport'

NUM_VALUES_PER_LINE = 20

class SerialIO
  def initialize(app, window, frequency)
    @buffer = ""
    # The Arduino when removed and plugged in again, sometimes shows as ttyACM1
    port_str = File.exists?('/dev/ttyACM0') ? '/dev/ttyACM0' : '/dev/ttyACM1'
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @app = app
    @window = window
    @frequency = frequency

    app.addTimeout(@frequency, method(:handle_input))
  end

  def handle_input(*args)
    parse_input(@fd.readline)           # blocks until line is read
    # poor man's buffer ensures reasonably fresh data next time
    # TODO: check if this is of any use with the Arduino
  rescue EOFError               # probably not required for Arduino
  ensure
    @app.addTimeout(@frequency, method(:handle_input))
  end

  ########
  private
  ########

    def parse_input(s)
      @buffer << s
      if (line_start = @buffer.index('^')) &&
         (line_end = @buffer.index('$', line_start + 1))

        line = @buffer.slice((line_start + 1)...line_end)
        values = line.split(' ').collect { |i| i.to_f }
        if values.count == NUM_VALUES_PER_LINE
          angles_actual = values[0..2]
          angles_desired = values[3..5]
          throttle = values[6]
          pitch_pid = values[7..9]
          roll_pid = values[10..12]
          yaw_pid = values[13..15]
          motors = values[16..19]

          @window.update_values(angles_actual, angles_desired, throttle,
                                pitch_pid, roll_pid, yaw_pid, motors
                               )
        end

        @buffer.clear
        puts line
      end
    end
end
