class Accuracy
  attr_accessor :answer, :relevant
  attr_reader :precision, :recall
  # answer, relevant are sets
  def initialize(answer, relevant)
    @answer = answer
    @relevant = relevant
    @precision = answer.count == 0 ? 0 : ((@answer & @relevant).count.to_f / @answer.count.to_f)
    @recall = relevant.count == 0 ? 0 : ((@answer & @relevant).count.to_f / @relevant.count.to_f)
  end

  def harmonic_mean
    # puts "precision: #{@precision.to_f}"
    # puts "recall: #{@recall.to_f}"
    if @precision.to_f == 0 && @recall.to_f == 0
      harmonic_mean = 0
    else
      # 2*precision*recall/precision+recall
      harmonic_mean = (2.00 * @precision.to_f * @recall.to_f) / (@precision.to_f + @recall.to_f)
    end
  end

  def jaccard
    if @precision.to_f == 0 && @recall.to_f == 0
      jaccard = 0
    else
      # precision*recall/(precision+recall-precision*recall)
      jaccard = (@precision.to_f * @recall.to_f) / (@precision.to_f + @recall.to_f - @precision.to_f * @recall.to_f)
    end
  end
end
