class MarkovChain
  attr_accessor :num_conditions
  attr_reader :matrix, :res, :p
  def initialize(num_conditions, first_condition = 0, initial_p = nil, initial_matrix = nil)
    @num_conditions = num_conditions
    @first_condition = first_condition
    @res = {}

    @p = initial_p || initialize_initial_distribution
    @matrix =  initial_matrix || create_matrix
  end

  def initialize_initial_distribution
    @p = (1..@num_conditions).to_a.map{|e|  e = 1 / @num_conditions.to_f}
  end

  def create_matrix
    if @num_conditions > 0
      @matrix = []
      1.upto(@num_conditions) do |n|
        tmp = (1..@num_conditions).map{|e| rand(@num_conditions)}
        @matrix << tmp.map{|e| (e.to_f / (tmp.inject :+)).round(2) }
      end

      @matrix
    else
      puts "Задайте число станів більше за нуль!!!"
    end
  end

  def show_matrix
    if @matrix
      for rows in @matrix
        for e in rows
          print "#{sprintf('%.2f', e)} "
        end
        print "\n"
      end
    end
  end

  def one_condition(prev_condition)
    next_condition(prev_condition, rand)
  end

  def chain(num = 5)

    if num > 0
      current_condition = @first_condition

      # res[:first] = current_condition

      1.upto(num) do |n|
        random = rand
        res[random] = current_condition
        current_condition = next_condition(current_condition, random)
        # p "#{random}"
        # p "#{current_condition}"
      end
      res
    end
  end

  private

  def next_condition(condition, random)
    row = @matrix[condition]
    # p row
    i = 0

    a = 0.0

    while ! ( (random >= a) && (random < a + row[i]) )
      a += row[i]
      i += 1
    end
    i
  end
end

# example = MarkovChain.new(5)

# example.create_matrix

# example.show_matrix

# p example.chain(5)