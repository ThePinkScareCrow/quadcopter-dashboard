require 'serialport'

NUM_VALUES_PER_LINE = 20

class SerialIO
  def initialize(app, window, frequency)
    @buffer = ""
    # The Arduino when removed and plugged in again, sometimes shows as ttyACM1
    port_str = File.exist?('/dev/ttyACM0') ? '/dev/ttyACM0' : '/dev/ttyACM1'
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @app = app
    @window = window
    @frequency = frequency

    # check for input from Arduino every @frequency milliseconds
    app.addTimeout(@frequency, method(:handle_input))
  end

  def handle_input(*args)
    parse_input(@fd.readline)           # blocks until line is read or EOF
  rescue EOFError
  ensure
    @app.addTimeout(@frequency, method(:handle_input))
  end

  # Simply sends the string it receives to the Arduino followed by a
  # newline character. It also echoes the same to STDOUT
  def send_output(string)
    @sp.puts string
    @sp.flush
    STDOUT.puts string
  end

  ########
  private
  ########

    def parse_input(s)
      @buffer << s
      if (m = @buffer.match(/\^(.*?)\$/))
        line = m[1]
        puts line

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

        # Clear buffer when one line has been read. This does lead to
        # missing lines of data -- but is perfectly acceptable and
        # ensures fresh data on next read
        @buffer.clear
      end
    end
end
