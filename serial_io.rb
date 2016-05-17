require 'serialport'

class SerialIO
  def initialize(app, window, refresh_frequency)
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
  end

  # Simply sends the string it receives to the Arduino followed by a
  # newline character. It also echoes the same to STDOUT
  def send_output(string)
    @sp.puts string
    @sp.flush
  end

  ########
  private
  ########

    def write_unparsed(string)
      @backup_file.write(string)
    end
end
