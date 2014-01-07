# PA based decision model with monitoring
#require 'rubygems'
require 'lpsolve'

class DecisionModel

  def initialize(succ_util, fail_util, abstain_util)
    @succ_util = succ_util
    @fail_util = fail_util
    @abstain_util = abstain_util
    # linear solver
    @lp = LPSolve.new(0,2)
  end

  # select a preferred agent and contract
  def select_agent(candidates, conditional_ratings)
    contracts = {}
    candidates.each do |a|
      effort_costs = a.get_effort_costs
      conditional_rating = conditional_ratings[a]
      # for each effort level, compute minimal contract
      conditional_rating.each do |effort, rating|
        eprobs = [rating, 1-rating]
        print effort_costs
        effort_cost = effort_costs[effort]
        # set the objective function coefficients
        @lp.str_set_obj_fn("#{eprobs[0]} #{eprobs[1]}")
        # set objective constant (on RHS)
        @lp.set_rh(0,effort_cost)
        # set constraints - participation:
        @lp.str_add_constraint("#{eprobs[0]} #{eprobs[1]}", LPSolve::GE, @abstain_util + effort_cost)
        # set constraints - incentive compatibility:
        conditional_ratings[a].each do |eff, p_succ|
          unless eff == effort
            @lp.str_add_constraint("#{eprobs[0]} #{eprobs[1]} -#{p_succ} -#{1-p_succ}", LPSolve::GE, effort_cost - effort_costs[eff])
          end
        end
        # TODO - need to still: extract best solution contracts, then find best
        # contract among candidates - the return value needs to be an agent AND
        # contract parameters for it!
        solution = @lp.solve
        @lp.print_objective
        @lp.print_solution(1)
      end
    end
  end

end
