class HmpsController < ApplicationController

  before_filter :set_params, only: [:index, :hmp]

  def index
    @chain = MarkovChain.new(@count_conditions)
    @chain.chain(@count_values)
  end

  def hmp
    real_conditions = @conditions.split(' ')
    @hmp = Hmm.new(@count_hidden, real_conditions.size)
    @hmp.conditions = real_conditions
    @hmp.initialize_emission_matrix
    @hmp.build(@count_values)
    @hmp.create_series

    # binding.pry
    # @data = @hmp.series.to_json
  end

  private

  def set_params
    @count_conditions = (hmp_params[:count_conditions] || 5).to_i
    @conditions = (hmp_params[:conditions] || 'red green yellow blue orange pink')
    @count_values = (hmp_params[:count_values] || 15).to_i
    @count_hidden = (hmp_params[:count_hidden] || 3).to_i
  end

  def hmp_params
    params.permit(:count_conditions, :conditions, :count_values, :count_hidden)
  end

end