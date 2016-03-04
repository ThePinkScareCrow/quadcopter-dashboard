require 'serialport'

NUM_VALUES_PER_LINE = 20

class SerialIO
  def initialize(app, window, refresh_frequency)
    @buffer = ""
    # The Arduino when removed and plugged in again, sometimes shows as ttyACM1
    port_str = File.exist?('/dev/ttyACM0') ? '/dev/ttyACM0' : '/dev/ttyACM1'
    baud_rate = 115200
    data_bits = 8
    stop_bits = 1
    parity = SerialPort::NONE

    @sp = SerialPort.new(port_str, baud_rate, data_bits, stop_bits, parity)
    @backup_file = File.open(ARGV.first, 'a') if ARGV.first

    @app = app
    @window = window
    @refresh_interval = 1000 / refresh_frequency

    # check for input from Arduino every @refresh_interval milliseconds
    app.addTimeout(@refresh_interval, method(:handle_input))
  end

  def handle_input(*args)
    string = @fd.readline
    parse_input(string)           # blocks until line is read or EOF
    write_unparsed(string) if @backup_file
  rescue EOFError
  ensure
    @app.addTimeout(@refresh_interval, method(:handle_input))
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

    def write_unparsed(string)
      @backup_file.write(string)
    end

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
