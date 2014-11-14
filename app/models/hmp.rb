class Hmp
  attr_reader :models, :result, :series
  def initialize(num_hidden, num_markov_condition = 5)
    @hidden = num_hidden
    @markov_condition = num_markov_condition
    @models = (0..@hidden).map{|e| MarkovChain.new(@markov_condition)}
    @result = []
    @series = []
  end

  def build(count = 10)
    @result = []
    random = rand(@hidden)
    @result << {num_model: random, value: @models[random].one_condition(0)}
    1.upto(count-1) do |e|
      random = rand(@hidden)
      @result << {num_model: random, value: @models[random].one_condition(@result.last[:value])}
    end
  end

  def create_series
    # build if @result.empty?
    0.upto(@hidden) do |num|
      @series << []
      @series[num] = {data: []}
      @result.each_with_index do |e, index|
        @series[num][:data] << [index,num, e[:value]] if e[:num_model] == num
      end
    end
    @series.pop
  end

end