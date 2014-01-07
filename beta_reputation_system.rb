# this class models the beta reputation system (Josang 2002)

class BetaReputationSystem

  attr_reader :evidence, :ratings

  def initialize
    # store of positive/negative observations after interactions
    @evidence = Hash.new([0.0,0.0])
    @ratings = Hash.new(0.5)
  end

  # take a list of agents to evaluate, and a list of recommenders
  # return a set of evaluations based on own experience and recommendations
  def evaluate(agents, recommenders)
    # gather reputational evidence
    rep_evidence = {}
    agents.each do |a|
      rep_evidence[a] = [0.0,0.0]
      recommenders.each do |r|
        ev = r.reputation_query(a)
        rep_evidence[a][0] += ev[0]
        rep_evidence[a][1] += ev[1]
      end
      # aggregate with own observations
      @evidence[a][0] += rep_evidence[a][0]
      @evidence[a][0] += rep_evidence[a][0]
      @ratings[a] = compute_rating(@evidence[a][0], @evidence[a][1])
    end
    @ratings
  end

  def add_evidence(agent, outcome)
    outcome ? @evidence[agent][0] += 1 : @evidence[agent][1] += 1
  end

  def compute_rating(pos, neg)
    (pos + 1) / (pos + neg + 2)
  end


end
