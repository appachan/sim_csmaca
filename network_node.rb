class NetworkNode
  # const for ch_status
  BUSY = 0
  IDLE = 1

  # const for status
  WF_NAV = 0
  WF_DIFS = 1
  WF_SIFS = 2
  WF_CTS = 3
  WF_DATA = 4
  WF_ACK = 5

  # coordinate of node
  @coordinate
  # its ch status
  @ch_status
  # node status (WF_DIFS ... etc)
  @status
  # in BOC true/false
  @inBOCounting

  # コンストラクタ
  def initialize()
    # set ch_status => idle
    @ch_status = 1
    @inBOCounting = false
    # ToDo: init status
  end

  # 送信
  def transmit()
  end

  # 受信
  def receive()
  end

  # chの状態チェック
  def isIdle()
    if @ch_status == IDLE
      retv = true
    else
      retv = false
    end
    retv
  end

  # ルーチン
  def routine()
  end
end