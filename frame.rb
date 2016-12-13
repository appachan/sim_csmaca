class Frame
  attr_accessor :destination, :sender, :type

  # node id
  NODE_ID = {"AP"=>0, "A"=>1, "B"=>2, "C"=>3, "D"=>4, "E"=>5, "F"=>6, "G"=>7, "H"=>8, "I"=>9, "J"=>10, "K"=>11, "L"=>12, "M"=>13, "N"=>14, "O"=>15, "P"=>16}

  PAYLOAD_SIZE = 1000 #bytes
  T_PREAMBLE = 16 # micro sec
  T_SIGNAL = 4
  T_SYMBOL = 4
  N_BIT_PER_SYM = {6=>24, 9=>36, 12=>48, 18=>72, 24=>96, 36=>144, 48=>192, 54=>216} # Mbps => BitPerSym

  # frame type
  DATA = 0
  RTS_CTS_ACK = 1

  @size
  @type
  @sender
  @destination

  def initialize(frame_type, sender, destination)
    @type = frame_type
    @sender = sender
    @destination = destination

    if @type == DATA
      @size = (64 + PAYLOAD_SIZE)*8 + 22
    elsif @type == RTS_CTS_ACK
      @size = 14*8 + 22
    end
  end

  # 宛先を取得
  def get_destination()
    @destination
  end

  # 送信時間を計算
  def get_time(speed)
    time_for_transmit = T_PREAMBLE + T_SIGNAL + T_SYMBOL * (@size / N_BIT_PER_SYM[speed]).ceil
    return time_for_transmit
  end
end