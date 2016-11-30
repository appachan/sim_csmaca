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
  WF_BOC = 6

  # waiting time
  T_SIFS = 16
  T_SLOT = 9
  T_DIFS = T_SIFS + T_SLOT * 2

  # coordinate of node
  @coordinate
  # its ch status
  @ch_status
  # node status (WF_DIFS ... etc)
  @status = []
  # in BOC true/false
  # @inBOCounting
  # 送信フレーム
  @frame
  # 状態終了までのn /microsec
  @statusCounter

  # コンストラクタ
  def initialize()
    # set ch_status => idle
    @ch_status = 1
    # @inBOCounting = false
    # ToDo: init status => nodeの種類によって初期化値が異なるのでサブクラスに任せる
    @status = [] # ここで初期化してやる必要あり
  end

  # 送信
  def transmit()
  end

  # 受信
  def receive()
  end

  def to_a_status(status_id)
    # status遷移時の処理
    @status.push(status_id)
    if status_id == WF_DIFS
      @statusCounter = T_DIFS
    else status_id == WF_SIFS
      @statusCounter = T_SIFS
    else status_id == WF_BOC
      @statusCounter = T_SLOT
    end
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