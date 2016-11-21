class AccessPoint < NetworkNod
  # const

  # values in superclass
  @coordinate
  @ch_status
  @status
  @frame

  # values in this class
  @threshold
  @BOCounter
  @CW
  @statusCounter # 状態終了までのn /microsec

  alias :super_isIdle :isIdle

  def initialize(coordinate, threshold) # coordinate => 座標, threshold => 閾値
    super()
    @coordinate = coordinate
    @threshold = threshold
    @CW = CWmin
  end

  def transmit()
  end

  def receive()
  end

  # CWの一様分布から設定
  def setBOC()
    r = Random.new()
    @BOCounter = r.rand(@CW) + 1
  end

  # 引数にしたがってCWを設定
  def setCW()
    newCW = 2 * @CW + 1
    @CW = newCW < CWmax ? newCW : CWmax
  end

  # BOカウント 一応例外処理
  def countDownBOC()
    if super_isIdle == 1
      @BOCounter -= 1
    else
      false
    end
  end

  def routine()
  end
end