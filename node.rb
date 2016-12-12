class Node
  attr_accessor :received_frames

  # node id
  NODE_ID = {"AP"=>0, "A"=>1, "B"=>2, "C"=>3, "D"=>4}

  # status_id
  IDLE = 0
  WF_NAV = 1
  WF_DIFS = 2
  #WF_CTS = 3
  WF_DATA = 4
  WF_ACK = 5
  WF_BOC = 6
  #WF_RTS = 7
  IN_TRANSMITTING_DATA = 8
  IN_TRANSMITTING_ACK = 9

  # waiting time
  T_SIFS = 16
  T_SLOT = 9
  T_DIFS = T_SIFS + T_SLOT * 2

  # const for CW
  CWmin = 15
  CWmax = 127

  # frame type
  DATA = 0
  ACK = 1

  # values in superclass
  @coordinate
  @status # = [] statusはstackで管理
  @frame_for_DATA
  @frame_for_ACK
  @frame_example_ACK # 送信時間計算用のモデル
  @received_frames # = []
  @new_received_frames
  @status_counter # 状態終了までのn /microsec

  # values in this class
  @threshold
  @BOCounter
  @CW
  @node_id


  @need_for_refresh = false

  def initialize(coordinate, threshold, node_id) # coordinate => 座標, threshold => 閾値
    super()
    # とりあえずDIFS待ちということで
    @status = []
    @status.push(IDLE)
    @node_id = node_id
    @coordinate = coordinate
    @threshold = threshold
    @frame_for_DATA = Frame.new(DATA, @node_id, NODE_ID["AP"])
    @frame_example_ACK = Frame.new(ACK, @node_id, NODE_ID["AP"])
    @CW = CWmin
    @BOCounter = 0
    @received_frames = []
    @new_received_frames = []
  end

  def routine(receivers_list, transmitting_speed) # 他端末リスト, レートテーブルにおける任意の送信速度（MAC層による処理と仮定）
    @current_status = @status.pop()
    initial_status = @current_status
=begin
    i_am()
    print @received_frames
    print @new_received_frames
    puts
=end
    if @current_status == IDLE
      if has_frame_to_others() # 他端末宛フレームを受信
        @status.push(WF_NAV)
        @status_counter = -1 + T_SIFS + @frame_example_ACK.get_time(transmitting_speed) + @frame_for_DATA.get_time(transmitting_speed)
      elsif is_idle(receivers_list) # CH idle フレームなし
        @status.push(WF_DIFS)
        @status_counter = T_DIFS
      elsif has_frame_to_me() # 自分宛のDATAフレームを受信
        # ここで分岐入れる必要ありそう
        # DATAが1件か複数件か
        received_DATAs = @received_frames.select {|frame| frame.type == DATA}
        if received_DATAs.length > 1
          i_am()
          puts "collision!"
          @need_for_refresh = true
          @status.push(IDLE)
        else
          frame_to_me = received_DATAs.pop()
          makeACK(frame_to_me.sender)
          @status.push(WF_DATA)
          @status_counter = T_SIFS + frame_to_me.get_time(transmitting_speed)
          @need_for_refresh = true
        end
      else
        @need_for_refresh = true
        @status.push(IDLE)
      end

      if @status[0] != IDLE
        @current_status = @status.pop()
      end
    end


    if @current_status == WF_BOC
      @status_counter -= 1
      if is_busy(receivers_list)
        @status.push(IDLE)
        @status_counter = T_SLOT
      elsif @status_counter <= 0
        @BOCounter -= 1
        if @BOCounter <= 0
          transmit(receivers_list, @frame_for_DATA)
          @status.push(IN_TRANSMITTING_DATA)
          # IN_TRANSMITTING_DATA に入る際は @status_counter = T_TRANSMIT + T_SIFS
          @status_counter = @frame_for_DATA.get_time(transmitting_speed) + T_SIFS
=begin
        elsif is_busy(receivers_list) # busy
          @status.push(IDLE)
          @status_counter = T_SLOT
=end
        else # idle && BOC > 0
          @status.push(WF_BOC)
          @status_counter = T_SLOT
          @need_for_refresh = true
        end
      else
        @status.push(WF_BOC)
      end

    elsif @current_status == WF_NAV
      @status_counter -= 1
      if @status_counter <= 0
        @status.push(WF_DIFS)
        @status_counter = T_DIFS
        @need_for_refresh = true
      else
        @status.push(WF_NAV)
      end

    elsif @current_status == WF_DIFS
      @status_counter -= 1
      if @status_counter <= 0
        if is_busy(receivers_list)
          @status.push(IDLE)
        elsif @BOCounter <= 0 && !isAP()
          transmit(receivers_list, @frame_for_DATA)
          @status.push(IN_TRANSMITTING_DATA)
          # IN_TRANSMITTING_DATA に入る際は @status_counter = T_TRANSMIT + T_SIFS
          @status_counter = @frame_for_DATA.get_time(transmitting_speed) + T_SIFS
        elsif !isAP()
          @status.push(WF_BOC)
          @status_counter = T_SLOT
          @need_for_refresh = true
        elsif isAP()
          # しんどい
          if has_frame_to_me() # 自分宛のDATAフレームを受信
            # ここで分岐入れる必要ありそう
            # DATAが1件か複数件か
            received_DATAs = @received_frames.select {|frame| frame.type == DATA}
            if received_DATAs.length > 1
              i_am()
              puts "collision!"
              @need_for_refresh = true
              @status.push(IDLE)

            else
              frame_to_me = received_DATAs.pop()
              makeACK(frame_to_me.sender)
              @status.push(WF_DATA)
              @status_counter = T_SIFS + frame_to_me.get_time(transmitting_speed)
              @need_for_refresh = true
            end
          else
            @status.push(IDLE)
          end
        else
          # ToDo
          i_am
          puts "想定してないよ"
        end
      elsif has_frame_to_me() # 自分宛のDATAフレームを受信
        # ここで分岐入れる必要ありそう
        # DATAが1件か複数件か
        received_DATAs = @received_frames.select {|frame| frame.type == DATA && rssi(frame.sender, receivers_list)}
        if received_DATAs.length > 1
          i_am()
          puts "collision!"
          @need_for_refresh = true
          @status.push(IDLE)

        else
          frame_to_me = received_DATAs.pop()
          makeACK(frame_to_me.sender)
          @status.push(WF_DATA)
          @status_counter = T_SIFS + frame_to_me.get_time(transmitting_speed) - 1
          @need_for_refresh = true
        end
      else
        @status.push(WF_DIFS)
        @need_for_refresh = true
      end

    elsif @current_status == WF_ACK
      @status_counter -= 1
      if @status_counter <= 0
        if hasACK_to_me()
          reset_cw()
          @BOCounter = 0
          @status.push(IDLE)

          i_am()
          puts "Transmission succeeded."

        else
          set_cw()
          set_boc()
          @status.push(WF_DIFS)
          @status_counter = T_DIFS

          i_am()
          puts "Transmission failed...."

        end
        @need_for_refresh = true
      else
        @status.push(WF_ACK)
      end

    elsif @current_status == IN_TRANSMITTING_DATA
      @status_counter -= 1
      if @status_counter <= 0
        @status.push(WF_ACK)
        @status_counter = @frame_example_ACK.get_time(transmitting_speed)
        @need_for_refresh = true
      else
        @status.push(IN_TRANSMITTING_DATA)
      end

    elsif @current_status == IN_TRANSMITTING_ACK
      @status_counter -= 1
      if @status_counter <= 0
        @status.push(IDLE)
      else
        @status.push(IN_TRANSMITTING_ACK)
      end

    elsif @current_status == WF_DATA
      @status_counter -= 1
      if @status_counter <= 0
        # 適切に宛先を指定してやる必要性 => ここにくるまえにmakeACK
        # 送った時に送り先を記憶しておくといいかな
        i_am()
        puts "started to transmit ACK"
        transmit(receivers_list, @frame_for_ACK)
        @status.push(IN_TRANSMITTING_ACK)
        @status_counter = @frame_for_ACK.get_time(transmitting_speed)
      else
        @status.push(WF_DATA)
      end

    end
    i_am()
    # print " " + status_name(initial_status) + " => " + status_name(@current_status) + " => " + status_name(@status[0])
    print status_name(@status[0])
    puts
  end

  def transmit(receivers_list, frame_to_transmit)
    receivers_list.each{|receiver|
      receiver.receive(frame_to_transmit)
    }
  end

  def receive(frame)
    @new_received_frames.push(frame)
  end

  # CWの一様分布から設定
  def set_boc()
    r = Random.new()
    @BOCounter = r.rand(@CW) + 1
    i_am()
    puts "BOC set to " + @BOCounter.to_s
    return @BOCounter
  end

  def set_cw()
    newCW = 2 * @CW + 1
    @CW = newCW < CWmax ? newCW : CWmax

    i_am()
    puts "CW set to " + @CW.to_s
    return @CW
  end

  def reset_cw()
    @CW = CWmin
    i_am()
    puts "CW reset to " + @CW.to_s
    return @CW
  end

  def rssi(opponent_id, receivers_list)
    h_tx = 1.5
    h_rx = 1.5
    g_tx = 1.0
    g_rx = 1.0
    l_1 = 1.25
    l_2 = 2.5
    lambda_c = 0.125
    p_tx_dBm = 20

    opponent_coordinate = []
    receivers_list.each do |receiver|
      if receiver.get_node_id() == opponent_id
        opponent_coordinate = receiver.get_coordinate()
      end
    end
    if opponent_coordinate.empty?
      puts "相手の座標が空です"
    end

    d = Math.sqrt((@coordinate[0]-opponent_coordinate[0])**2 + (@coordinate[1]-opponent_coordinate[1])**2)
    d_crossover = (4 * Math::PI * h_tx * h_rx) / lambda_c
    m = lambda_c / (4 * Math::PI * d)
    if d < d_crossover
      pr = (g_tx * g_rx * m**2) / l_1
    else
      pr = (g_tx * g_rx * h_tx**2 * h_rx**2) / (d**4 * l_1)
    end
    pr_dBm = 10 * Math.log10(pr) + p_tx_dBm
    rssi = pr_dBm - l_2

    rssi > @threshold
  end

  # terminal向けメソッド
  # refresh前にフレームの送信先を記録してしまう
  def makeACK(destination)
    @frame_for_ACK = Frame.new(ACK, @node_id, destination)
    return @frame_for_ACK
  end

  # AP向けメソッド
  def makeDATA(destination)
    @frame_for_DATA = Frame.new(DATA, @node_id, destination)
    return @frame_for_DATA
  end

  def hasACK()
    has = false
    @received_frames.each do |frame|
      if frame.type == ACK
        has = true
        break
      end
    end
    return has
  end

  def hasACK_to_me()
    has = false
    # puts "cei" + @received_frames.pop().destination.to_s
    @received_frames.each do |frame|
      if frame.destination == @node_id && frame.type == ACK && frame.sender == @frame_for_DATA.destination
        has = true
        break
      end
    end
    return has
  end

  # 他端末宛フレーム受信(ACK以外)
  def has_frame_to_others()
    has = false
    @received_frames.each do |frame|
      if frame.type != ACK && frame.destination != @node_id
        has = true
        break
      end
    end
    return has
  end

  # idle
  def is_idle(receivers_list)
    is_idle = true
    if @received_frames.empty?
      is_idle = true
    else
      @received_frames.each do |frame|
        if rssi(frame.sender, receivers_list)
          is_idle = false
          break
        end
      end
    end

    return is_idle
  end

  # busy
  def is_busy(receivers_list)
    is_busy = false
    if @received_frames.empty?
      is_busy = false
    else
      @received_frames.each do |frame|
        if rssi(frame.sender, receivers_list)
          is_busy = true
          break
        end
      end
    end

    return is_busy
  end

  # 自分宛のDATAフレームを受信
  def has_frame_to_me()
    frame_to_me = false
    @received_frames.each do |frame|
      if frame.type == DATA && frame.destination == @node_id
        frame_to_me = true
        break
      end
    end
    return frame_to_me
  end

  # 今回の実験ではAPはDATAフレームの送信を行わない
  def isAP()
    @node_id == NODE_ID["AP"]
  end

  def get_coordinate()
    @coordinate
  end

  def get_node_id()
    @node_id
  end

  # 外から呼び出して使用
  def refresh_frames_list()
    if @need_for_refresh == true
      @received_frames = @new_received_frames
      @new_received_frames = []
      @need_for_refresh = false
    end
  end

  def i_am()
    names = NODE_ID.invert
    print names[@node_id] + " ==> "
  end

  def status_name(status_id)
    if status_id.nil?
      return "1"
    else
      status = ["IDLE", "WF_NAV", "WF_DIFS", "WF_CTS", "WF_DATA", "WF_ACK", "WF_BOC", "WF_RTS", "IN_TRANSMITTING_DATA", "IN_TRANSMITTING_ACK"]
      status[status_id]
    end
  end
end