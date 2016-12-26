class Hmm
  attr_accessor :markov_condition, :num_events, :model, :emissions, :result, :series, :total
  def initialize(num_markov_conditions = 3, num_events = 5, initial_model = nil, emission_matrix = nil)
    @markov_condition = num_markov_conditions
    @num_events = num_events
    @model = initial_model || MarkovChain.new(@markov_condition)

    @emissions = emission_matrix || initialize_emission_matrix
  end

  def initialize_emission_matrix
    keys = (:a..:z).to_a.take(num_events)
    # :a - червона кулька
    # :b - зелена кулька
    # :c - синя кулька
    # ..................

    @emissions = []
    (1..markov_condition).to_a.each do |i|
      e = {}
      sum = 0.0
      keys.each do |k|
        e[k] = {value: rand(10)}
        sum += e[k][:value]
      end

      keys.each do |k|
        e[k][:probability] = e[k][:value]/sum
      end

      @emissions << e
    end

    @emisions
  end

  def build(total = 10)
    @total = total
    @result = []
    random = rand

    @result << { value: get_ball(0, random), condition: 0, random: random}

    1.upto(total-1) do |e|
      condition = model.one_condition(@result.last[:condition])
      random = rand
      @result << {value: get_ball(condition, random), condition: condition, random: random}
    end
  end

  def get_ball(condition, random)
    row = emissions[condition]
    a = 0.0
    row.each do |k,v|
      if (random >= a) && (random < a + v[:probability])
        return k
      end
      a += v[:probability]
    end
  end
end