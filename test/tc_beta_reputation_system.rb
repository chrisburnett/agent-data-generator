require_relative '../beta_reputation_system'
require 'test/unit'

# test case to check that BRS is working
class TestBetaReputationSystem < Test::Unit::TestCase

  def setup
    @brs = BetaReputationSystem.new
  end

  def test_unknown_agent_lookup
    assert_equal(0.5, @brs.ratings[:newagent])
  end

  def test_rating_function
    assert_equal({:newagent => 0.5}, @brs.evaluate([:newagent], []))
    @brs.add_evidence(:newagent, true)
    @brs.evaluate([:newagent], [])
    assert_equal(0.6666666666666666, @brs.ratings[:newagent])
  end

end
