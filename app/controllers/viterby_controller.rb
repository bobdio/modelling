class ViterbyController < ApplicationController

  before_filter :set_params, only: [:index, :hmp]

  def index
  end

  def calculate
    @count_hidden = params[:count_hidden].to_i
    @observations = params[:observations].strip.split(' ')

    @init_distribution = params[:init_distribution].map do |_k,v|
      v.to_f
    end

    @matrix = params[:matrix].map do |_k,v|
      v.values.map(&:to_f)
    end

    @emissions = params[:emissions].map do |_k,v|
      res = {}
      @observations.each_with_index do |e, index|
        res[e] = {
            value: e,
            probability: v[index.to_s].to_f
        }
      end
      res
    end

    chain = MarkovChain.new(@count_hidden, 0, @init_distribution, @matrix)

    model = Hmm.new(@count_hidden,@observations.size,chain, @emissions)

    viterby = Viterby.new model

    viterby.hmm.result = params[:real_observations].strip.split(' ').map do |value|
      {
        value: value
      }
    end

    viterby.get

    render json: { q: viterby.q }
  end

  private

  def set_params
    @count_hidden = (hmp_params[:count_hidden] || 2).to_i
  end

  def hmp_params
    params.permit(:count_conditions, :count_values, :count_hidden)
  end

end