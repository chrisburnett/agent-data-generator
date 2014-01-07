# type determines competence characteristics as
# well as network structure and number of agents in type
require 'pp'

require_relative 'graphs/AgentGraph'
require_relative 'graphs/ScaleFreeGraph'
require_relative 'graphs/FullyConnectedGraph'
require_relative 'graphs/SmallWorldGraph'

require_relative 'agent'
require_relative 'type'




class Experiment

  # BEGIN PARAMETERS SECTION

  # Experiment setting of types
  # amount to perturb agent competencies by
  PERTURB_RANGE=[-0.2,0.2]
  #Utility gain for successful and unsuccessful interactions
  SUCC_UTIL = 50
  ABSTAIN_UTIL = 0
  FAIL_UTIL = -10

  TYPES = {
    :good => Type.new( { :high => { :succ_prob => 0.8, :cost => -20 },
                         :low => { :succ_prob => 0.3, :cost =>-10 }},
                       PERTURB_RANGE,
                       15),
    :mediocre => Type.new( {:high =>{ :succ_prob =>0.6, :cost => -20},
                            :low => { :succ_prob=> 0.25, :cost => -10}},
                           PERTURB_RANGE,
                           15),
    :bad  => Type.new( { :high => { :succ_prob => 0.4, :cost => -20 },
                         :low => { :succ_prob => 0.2, :cost =>-10 }},
                       PERTURB_RANGE,
                       15)
  }

  TYPES.each{ |t| t.utilities =
    { :succ_util => SUCC_UTIL,
      :fail_util => FAIL_UTIL,
      :abstain_util => ABSTAIN_UTIL
    }
  }

  # Limits for contract search
  MIN_REWARD = 10
  MIN_PUNISH = -120
  MAX_REWARD = 130
  MAX_PUNISH = 30

  # time steps for learning conditions
  TIME_STEPS = 100

  # The network topology we want to use
  TOPOLOGY = ScaleFreeGraph

  # END PARAMETERS SECTION

  def initialize
    @topology = TOPOLOGY.new
    # setup the agents according to type spec
    @agents = Array.new
    TYPES.values.each do |type|
      type.acount.times do
        ag = Agent.new(type)
        @agents << ag
        @topology.addAgent(ag)
      end
    end
  end

  # oops... massive explosion!
  def run(runs)
    # create results tables for each condition we are evaluating
    resultset = {}
    [:c0].each do |condition|
      resultset[condition] = Array.new(MAX_PUNISH - MIN_PUNISH + 1) { |c| Array.new(MAX_REWARD - MIN_REWARD + 1, 0) }
    end
    # create headers for the tables (axes)
    hheader = Array.new
    vheader = Array.new
    hheader << ""
    (MIN_REWARD..MAX_REWARD).each do |i| hheader << i end
    (MIN_PUNISH..MAX_PUNISH).each do |i| vheader << i end

    # structures to store the maximum points in the global sweep
    maximums = {:best_su => 0, :best_reward => 0, :best_punish => 0}
    c0_maxims = Hash[maximums]

    # repeat runs
    runs.times do |r|
      puts "run #{r}:"
      condition0(resultset[:c0], c0_maxims)
    end

    # take the average over the number of runs
    # average maximums and print
    # TODO - ENSURE FLOAT BEFORE AVERAGING - do we need to?
    c0_maxims.each { |k,v| c0_maxims[k] = v/runs }
    x = 0
    resultset.each do |c,rs|
      rs.each do |col|
        col.map! { |su| su/runs }
        # add 'row' heading
        col.unshift(vheader[x])
        x += 1
      end
      rs.unshift(hheader)
      plot(rs,c)
    end

    # print out maximums
    puts("Best SEU: #{c0_maxims[:best_su]}, best contract: #{c0_maxims[:best_reward]}, #{c0_maxims[:best_punish]}")

    # write out graph to image file
    @topology.generateGraph
    @topology.write_dot(TOPOLOGY.name)

  end

  def condition0(results, maximums)
    # counters for our results table
    x = 0
    # store maximum utility and indices
    best_su, best_reward, best_punish = 0,0,0
    # loop through every possible contract and all interactions...
    for i in MIN_PUNISH..MAX_PUNISH do
      y = 0
      for j in MIN_REWARD..MAX_REWARD do
        social_utility = 0
        @agents.each do |a|
          # for each agent in a's neighborhood
          for b in @topology.graph.neighborhood(a) do
            # C0 - contract sweep, no choiceadd this pair's outcome to the result
            social_utility += a.delegate(b,i,j)
          end
        end
        # record result
        results[x][y] += social_utility
        # note maximum SEU and contract so far
        if social_utility > best_su then
          best_su = social_utility
          best_reward = j
          best_punish = i
        end
        y += 1
      end
      # reset table counter
      x += 1
    end

    # update maximums for averaging later
    maximums[:best_su] += best_su
    maximums[:best_reward] += best_reward
    maximums[:best_punish] += best_punish

  end

  def condition1(results)
    # loop through every possible contract and all interactions...
    for i in MIN_PUNISH..MAX_PUNISH do
      y = 0
      for j in MIN_REWARD..MAX_REWARD do

      end
    end

  end


  # moment of truth
  # need to take the average of 10~20 runs in each cell
  # print header
  def plot(results, filename)
    result_string = ""
    results.each do |col|
      x = 0
      col.each do |row|
        result_string << "#{row}"
        unless x == results.length-1
          result_string << ", "
        end
        x += 1
      end
      result_string << "\n"
    end
    File.open("#{filename}.csv", 'w') { |file| file.write(result_string) }
  end
end


# execute
ex = Experiment.new
ex.run(ARGV[0].to_i)
