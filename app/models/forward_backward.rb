class ForwardBackward
  attr_accessor :hmm, :alpha, :beta

  def initialize(model=nil)
    @hmm = model #|| Hmm.new(2,5,chain, b)
  end

  def forward
    first_event = hmm_events.first

    @alpha = [[]]

    hmm.emissions.each_with_index do|row, index|
      @alpha[0] << hmm.model.p[index]*row[first_event][:probability]
    end

    hmm_events.each_with_index do |event, index|
      next if index == 0
      @alpha[index] = []
      hmm.emissions.each_with_index do|row, i|
        @alpha[index] << sum_prev(@alpha[index-1], i) * row[event][:probability]
      end
    end

  end

  def backward
    last_event = hmm_events.last
    @beta = []
    num_events = hmm_events.size

    hmm_events.each{|_e| @beta << [] }

    hmm.emissions.each_with_index do|row, index|
      @beta[num_events-1] << 1
    end

    i = num_events - 2

    while(i >= 0) do
      hmm.emissions.each_with_index do|row, index|
        @beta[i][index] = sum_next(i+1, index)
      end
      i -= 1
    end
  end

  def sum_next(num, i)
    sum = 0.0

    hmm.emissions.each_with_index do|row, index|
      sum += hmm.model.matrix[i][index] * row[hmm_events[num]][:probability]*@beta[num][index]
    end

    sum
  end

  def sum_prev(row, index)
    sum = 0.0
    row.each_with_index do |e, i|
      sum += e * hmm.model.matrix[i][index]
    end
    sum
  rescue => e
    binding.pry
  end

  def hmm_events
    hmm.result.map{|e| e[:value]}
  end

end