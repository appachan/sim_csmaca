class Terminal < NetworkNode
  # const for ch_status
  BUSY = 0
  IDLE = 1

  # status_id
  WF_NAV = 0
  WF_DIFS = 1
  WF_SIFS = 2
  WF_CTS = 3
  WF_DATA = 4
  WF_ACK = 5
  WF_BOC = 6
  WF_SLOT = 7

  # waiting time
  T_SIFS = 16
  T_SLOT = 9
  T_DIFS = T_SIFS + T_SLOT * 2

  # const for CW
  CWmin = 15
  CWmax = 127

  # values in superclass
  @coordinate
  @ch_status
  @status = [] # statusはstackで管理
  @frame
  # @inBOCounting
  @statusCounter # 状態終了までのn /microsec

  # values in this class
  @threshold
  @BOCounter
  @CW

  alias :super_isIdle :isIdle

  def initialize(coordinate, threshold) # coordinate => 座標, threshold => 閾値
    super()
    # とりあえずDIFS待ちということで
    self.to_new_status(WF_DIFS)
    @coordinate = coordinate
    @threshold = threshold
    @CW = CWmin

    # test
  end

  def transmit()
  end

  def receive()
  end

  def isIdle()
    super()
  end

  def to_new_status(status_id)
    # status遷移時の処理
    super(status_id)
    puts @statusCounter
  end

  def to_prev_status()
    # status遷移時の処理
    @status.pop()
  end

  # CWの一様分布から設定
  def set_boc()
    r = Random.new()
    @BOCounter = r.rand(@CW) + 1
  end

  # 引数にしたがってCWを設定
  def set_cw()
    newCW = 2 * @CW + 1
    @CW = newCW < CWmax ? newCW : CWmax
  end

  # BOカウント 一応例外処理
  # ToDo: 運用でt_slot毎に呼ぶ必要がある
  def countdown_boc()

  end

  def routine()
    if @status[0] == WF_BOC
      if isIdle() == true && @statusCounter > 0
        @BOCounter
        @statusCounter -= 1
        to_new_status(WF_SLOT)
      else
        countdown_boc()
      end
    else @status[0] == WF_SLOT
      if @statusCounter > 0
        @statusCounter -= 1
      else
        to_prev_status() # 常にWF_BOCが返ることが期待される
      end
    end
  end

  def test_method()
    @ch_status = 1
  end
end
