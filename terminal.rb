class Terminal < NetworkNode
  # const
  CWmin = 15
  CWmax = 127

  # values in superclass
  @coordinate
  @ch_status
  @status
  @frame
  @inRBCounting

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

    # test
  end

  def transmit()
  end

  def receive()
  end

  def isIdle()
    super()
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
  def countdown_boc()
    if isIdle() == true
      @BOCounter -= 1
    else
      false
    end
  end

  def routine()
    if @inRBCounting == true
      if @BOCounter > 0
        countdown_boc()
        puts @BOCounter
      end
    end
  end

  def test_method()
    @ch_status = 1
    @inRBCounting = true
  end
end
