require_relative 'beta_reputation_system'
require_relative 'decision_model'

class Agent

  def initialize(type)
    @efforts=type.perturbEfforts
    # useful to have an unconditional model - not used ATM
    @unconditional_tm=BetaReputationSystem.new
    # create a conditional trust model for each possible effort level
    @conditional_tms = {}
    @efforts.each_key do |k| @conditional_tms[k] = BetaReputationSystem.new end
    @utilities = type.utilities
    @decision_model=DecisionModel.new(type.utilities[:succ_util],
                                      type.utilities[:fail_util],
                                      type.utilities[:abstain_util])
  end

  def get_effort_costs
    effort_costs = {}
    @efforts.each { |k,v| effort_costs[k]=v[:cost] }
    effort_costs
  end

  def select_candidate(candidates)
    # update the conditional ratings
    # for each candidate, create an entry with their high and low rating
    conditional_ratings = Hash.new
    candidates.each do |a|
      conditional_ratings[a] = Hash.new
      @conditional_tms.each do |eff, tm|
        # TODO - we're not checking that we've updated the TM yet!!
        conditional_ratings[a][eff] = tm.ratings[a]
      end
    end
    # TODO - this also isn't actually selecting the best agent yet
    # but it should return the best agent and contract
    @decision_model.select_agent(candidates, conditional_ratings)
  end

  def delegate(agent, punishment, reward)
    # TODO - NEXT LINE TESTING ONLY
    select_candidate([agent])
    agent.perform(punishment, reward)
  end

  # here the logic actually goes. Principals are dumb - it's the 'agents' we
  # want to evaluate
  def perform(punishment, reward)
    # calculate EU of each effort
    eus = {}
    @efforts.each do |id, effort|
      eus[id] =
        (effort[:cost] + reward) * effort[:succ_prob] +
        (effort[:cost] + punishment) * (1-effort[:succ_prob])
    end
    # get best action
    best_effort = eus.max_by{ |k, v| v }[0]
    #if the expected utility for the principal is negative, they will abstain
    if eus[best_effort]<0
      return type.utilities[:abstain_util]
    end
    # simulate based on selected effort prob. of success
    #outcome = simulate(@myType.efforts[best_effort][:succ_prob])
    # We assume that the transfer of reward or penalty has no arbitrage, and
    # therefore has no net cost to  the system. Net system utility gain is thus
    # based on the agent's gain for the interaction, less the cost to the
    # principal.
    simulate(@efforts[best_effort][:succ_prob]) >0 ?
    @utilities[:succ_util]+@efforts[best_effort][:cost] :
    @utilities[:fail_util]+@efforts[best_effort][:cost]

  end

  def simulate(prob)
    # just return if random number 0..1 > prob
    rand < prob ? 1 : -1
  end

  # respond to a reputation query for an agent
  def reputation_query(agent)
    @trust_model.evidence[agent]
  end

end
