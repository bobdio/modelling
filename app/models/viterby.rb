class Viterby
  attr_accessor :hmm, :delta, :psi, :q

  def initialize
    @hmm = Hmm.new(4,7)
    @hmm.build(15)
  end


  def get
    first_event = hmm_events.first

    @delta = [[]]
    @psi = [[]]

    hmm.emissions.each_with_index do|row, index|
      @delta[0] << hmm.model.p[index]*row[first_event][:probability]
      @psi[0] << 0
    end

    hmm_events.each_with_index do |event, index|
      next if index == 0
      @delta[index] = []
      @psi[index] = []
      hmm.emissions.each_with_index do|row, i|
        max_data = max_prev(@delta[index-1], i)
        @delta[index] << max_data[:max] * row[event][:probability]
        @psi[index] << max_data[:argmax]
      end
    end


    last_row = @delta.last

    max = last_row[0]
    i_max = 0
    last_row.each_with_index do |e, index|
      if max < e
        max = e
        i_max = index
      end
    end


    @q = []
    num_events = hmm_events.size

    hmm_events.each{|_e| @q << -1 }
    
    @q[num_events-1] = i_max

    i = num_events - 2

    while(i >= 0) do
      @q[i] = @psi[i+1][@q[i]]
      i -= 1
    end

  rescue => e
    binding.pry
  end

  def max_prev(row, index)
    max = row[0] * hmm.model.matrix[0][index]
    i_max = 0

    row.each_with_index do |e, i|
      if max < e * hmm.model.matrix[i][index]
        max = e * hmm.model.matrix[i][index]
        i_max = i
      end
    end
    {
      max: max,
      argmax: i_max
    }
  rescue => e
    binding.pry
  end


  def hmm_events
    hmm.result.map{|e| e[:value]}
  end

end