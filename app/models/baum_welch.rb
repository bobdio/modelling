class BaumWelch
  attr_accessor :hmm, :fb, :gamma, :ksi, :p_new, :a_new, :b_new

  def initialize
    @hmm = Hmm.new(4,7)
    @hmm.build(15)

    initialize_forward_backward
    calculate_gamma
    calculate_ksi
  end

  def estimate
    @p_new = @gamma[0]

    @a_new = calculate_a

  rescue => e
    binding.pry
  end


  def calculate_a
    a = []
    @hmm.model.matrix.each_with_index do |row, i|
      a[i] = []
      row.each_with_index do |_e, j|
        a[i][j] = sum_ksi(i,j) / sum_gamma(i)
      end
    end
    a
  end

  def sum_ksi(i,j)
    sum = 0.0
    @ksi.each_with_index do |row, _index|
      sum += row[i][j]
    end

    sum
  end

  def sum_gamma(i)
    sum = 0.0
    @gamma.each_with_index do |row, _index|
      sum += row[i]
    end

    sum
  end



  def initialize_forward_backward
    @fb = ForwardBackward.new @hmm
    @fb.forward
    @fb.backward
  end

  def calculate_gamma
    @gamma = []
    @fb.alpha.each_with_index do |row, index|
      @gamma[index] = []
      row.each_with_index do |_e, j|
        @gamma[index][j] = (@fb.alpha[index][j] * @fb.beta[index][j]) / sum_row(index)
      end
    end
  end

  def calculate_ksi
    @ksi = []
    @fb.hmm_events.each_with_index do |event, t|
      break if t == (@fb.hmm_events.size-1)
      @ksi[t] = []
      @hmm.model.matrix.each_with_index do |row, i|
        @ksi[t][i] = []
        row.each_with_index do |_e, j|
          @ksi[t][i][j] = (@fb.alpha[t][i] * @hmm.model.matrix[i][j] * @fb.alpha[t+1][j] * @hmm.emissions[j][@fb.hmm_events[t+1]][:probability]) / sum_matrix(t)
        end
      end
    end
  end

  def sum_matrix(t)
    sum = 0.0
    @hmm.model.matrix.each_with_index do |row, i|
      row.each_with_index do |_e, j|
        sum += @fb.alpha[t][i] * @hmm.model.matrix[i][j] * @fb.alpha[t+1][j] * @hmm.emissions[j][@fb.hmm_events[t+1]][:probability]
      end
    end

    sum
  end

  def sum_row(index)
    sum = 0.0
    @fb.alpha[index].each_with_index do |e, j|
      #e = @fb.alpha[index][j]
      sum += e * @fb.beta[index][j]
    end

    sum
  end

end