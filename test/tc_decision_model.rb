require 'test/unit'
require_relative '../decision_model'

class TestDecisionModel < Test::Unit::TestCase

  def setup
    # create a load of fake stuff here as required
    # just fake an agent rather than dealing with the whole thing
    fake_agent = Class.new do
      def get_effort_costs
        {:low => 10, :high => 20}
      end
    end
    agent = fake_agent.new
    @candidates = [ agent ]
    @conditional_ratings = { agent => { :low => 0.3, :high => 0.6 } }

    @succ_util = 30
    @fail_util = -5
    @abstain_util = 10

  end

  def test_solver
    dm = DecisionModel.new(@succ_util, @fail_util, @abstain_util)
    dm.select_agent(@candidates, @conditional_ratings)

    assert(true)
  end


end
