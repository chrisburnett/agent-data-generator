require_relative 'parameters'
require 'csv'

class Agent
  attr_accessor :type, :id
  def initialize(type, id)
    @type = type
    @id = id
  end
end

class DataGen

  # init

  # - each time step
  # - each *available* (i.e. not delegating/delegated) agent picks a
  # partner at random and delegates, with probability
  # [interaction_prob]
  # - interacting agents are removed from the pool of possible
  # delegators/delegatees until delegation completes
  # - during delegation:
  #   - trustee generates an outcome each time step from its
  # performance function, this is recorded centrally (ground
  #                                                   truth)
  # - trustor observes (or doesn't) this value (stochastically) at
  #        each time step in the delegation - this is recorded in the
  #        agent's "memory"
  #                     - the end
  # export as "log" - simple file cat

  
  def initialize
    # agent lists
    @consumers = []
    @providers = []
    @interactions = []
    
    Parameters::PROVIDER_TYPES.each do |type| 
      type[:count].times do |n| 
        @providers << Agent.new(type, "P#{n}")
      end
    end

    Parameters::CONSUMER_TYPES.each do |type| 
      type[:count].times do |n| 
        @consumers << Agent.new(type, "C#{n}")
      end
    end
    
    # initially, everyone is available
    @providers_available = @providers.dup
    @consumers_available = @consumers.dup
    
    # output file
    @output = CSV.open("data/#{Date.today.iso8601}-data.csv", "w")

  end

  # main loop  
  def generate

    Parameters::TIME_STEPS.times do |t|

      # create new interactions
      @consumers_available.each do |consumer| 
        if rand < Parameters::INTERACTION_PROBABILITY
          # select a random partner - for evaluation, call to
          # evaluation/decision-making module could go here
          provider = @providers_available[rand(@providers_available.length)]
          # remove both agents from available list hopefully won't
          # cause a concurrent editing exception
          @consumers_available.delete(consumer)
          @providers_available.delete(provider)

          # create this interaction as ongoing with full 'life'
          interaction = { 
            consumer: consumer, 
            provider: provider, 
            life: Parameters::TASK_DURATION 
          }

          # record that an interaction started
          @output << [
                      t,
                      0,
                      "delegation_start",
                      interaction[:consumer].id,
                      interaction[:consumer].type[:class],
                      interaction[:provider].id,
                      interaction[:provider].type[:class],
                      "",
                      "",
                      "",
                     ]
          
          # add to ongoing interactions list
          @interactions << interaction
          
        end
      end

      # service 'live' interactions
      @interactions.each do |interaction| 
        # objective and subjective observation - might not be made
        # NOTE for now, only subjective (consumer) observation is
        # recorded
        ob = ""
        subj_ob = ""
        # every pair with time on the clock consumer might sample
        if rand < interaction[:consumer].type[:monitor_prob]
          # sample and perturb according to provider class
          sample = interaction[:provider].type[:function].call(t)
          noise = interaction[:provider].type[:noise]/2
          ob = rand(sample-noise..sample+noise)
          # perturb again for observer inaccuracy
          noise = interaction[:consumer].type[:noise]/2
          # subjective observation with noise applied
          subj_ob = rand(ob-noise..ob+noise)

          # write observation to file
          # Output columns:
          # timestep
          # interaction timestep
          # event id (?)
          # event type (delegation start/end or observation)
          # consumer id
          # provider id
          # provider noise (from profile)
          # consumer noise (from profile - for convenience)
          # objective_observation (null if start/end del event)
          # subjective_observation (null of not observed)
          it = Parameters::TASK_DURATION - interaction[:life]
          @output << [
                      t,
                      it,
                      "observation",
                      interaction[:consumer].id,
                      interaction[:consumer].type[:class],
                      interaction[:provider].id,
                      interaction[:provider].type[:class],
                      interaction[:consumer].type[:noise],
                      interaction[:provider].type[:noise],
                      subj_ob
                     ]
        end
        
        # decrement life
        interaction[:life] = interaction[:life] - 1

        # cleanup dead interactions and return agents to pool
        if interaction[:life] == 0
          @consumers_available << interaction[:consumer]
          @providers_available << interaction[:provider]
          @interactions.delete(interaction)
          @output << [
                      t,
                      it,
                      "delegation_end",
                      interaction[:consumer].id,
                      interaction[:consumer].type[:class],
                      interaction[:provider].id,
                      interaction[:provider].type[:class],
                      "",
                      "",
                      "",
                     ]
        end
      end
    end
    # close output file
    @output.flush
    @output.close
  end

  data_generator = DataGen.new
  data_generator.generate

end
