class Type

  :attr_accessor utilities

  def initialize(efforts, p_range, acount)
    @efforts = efforts
    @acount = acount
    @p_range = p_range
    @utilities = Hash.new(0)
  end

  def efforts
    @efforts
  end

  def acount
    @acount
  end

  def utilities
    @utilities
  end

  def perturbEfforts
    eff={}
    @efforts.each do |k,v|
      eff[k]={:succ_prob=>v[:succ_prob]+@p_range.min+(@p_range.max-@p_range.min)*rand , :cost=>v[:cost]}
      if eff[k][:succ_prob]<0
        eff[k][:succ_prob]=0
      elsif eff[k][:succ_prob]>1
        eff[k][:succ_prob]=1
      end
    end
    return eff
  end

end
