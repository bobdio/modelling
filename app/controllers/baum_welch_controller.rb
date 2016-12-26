class BaumWelchController < ApplicationController

  before_filter :set_params, only: [:index, :hmp]

  def index
    # @chain = MarkovChain.new(@count_conditions)
    # @chain.chain(@count_values)
  end

  def calculate
    @count_hidden = params[:count_hidden].to_i
    observations = params[:observations].strip.split(' ')

    init_distribution = params[:init_distribution].map do |_k,v|
      v.to_f
    end

    matrix = params[:matrix].map do |_k,v|
      v.values.map(&:to_f)
    end

    emissions = params[:emissions].map do |_k,v|
      res = {}
      observations.each_with_index do |e, index|
        res[e] = {
            value: e,
            probability: v[index.to_s].to_f
        }
      end
      res
    end

    chain = MarkovChain.new(@count_hidden, 0, init_distribution, matrix)

    model = Hmm.new(@count_hidden,observations.size,chain, emissions)

    result = params[:real_observations].strip.split(' ').map{|value| {value: value}}

    model.result = result
    bw = BaumWelch.new model
    bw.estimate

    i = 0

    while not_ok?(matrix, bw.a_new) && i < 100
      matrix = bw.a_new
      init_distribution = bw.p_new
      chain = MarkovChain.new(@count_hidden, 0, init_distribution, matrix)

      emissions = []
      bw.b_new.each_with_index do |v, k|
        res = {}
        observations.each_with_index do |e, index|
          res[e] = {
            value: e,
            probability: v[index].to_f
          }
        end
        emissions << res
      end

      model = Hmm.new(@count_hidden, observations.size, chain, emissions)

      model.result = result


      bw = BaumWelch.new model
      bw.estimate
      i += 1
    end

    render json: {
      p_new: bw.p_new,
      a_new: bw.a_new,
      b_new: bw.b_new,
      i: i
    }
  end

  def not_ok?(matrix1, matrix2)
    e = 0.01
    matrix1.each_with_index do |e1, i|
      matrix2.each_with_index do |e2, j|
       return true if (matrix1[i][j] - matrix2[i][j]).abs > e
      end
    end

    false
  end

  private

  def set_params
    @count_hidden = (hmp_params[:count_hidden] || 2).to_i
  end

  def hmp_params
    params.permit(:count_conditions, :count_values, :count_hidden)
  end

end