class HmpsController < ApplicationController

  before_filter :set_params, only: [:index, :hmp]

  def index
    @chain = MarkovChain.new(@count_conditions)
    @chain.chain(@count_values)
  end

  def hmp
    @hmp = Hmp.new(@count_hidden, @count_conditions)
    @hmp.build(@count_values)
    @hmp.create_series
    # @data = @hmp.series.to_json
  end

  private

  def set_params
    @count_conditions = (hmp_params[:count_conditions] || 5).to_i
    @count_values = (hmp_params[:count_values] || 15).to_i
    @count_hidden = (hmp_params[:count_hidden] || 3).to_i
  end

  def hmp_params
    params.permit(:count_conditions, :count_values, :count_hidden)
  end

end