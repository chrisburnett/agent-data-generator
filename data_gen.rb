require_relative 'parameters'
require_relative 'consumer'
require_relative 'provider'

class Agent
  attr_accessor :type
  def initialize(type)
    @type = type
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
    
    Parameters::PROVIDER_TYPES.each do |id, type| 
      type[:count].times do
        @providers << Agent.new(type)
      end
    end

    Parameters::CONSUMER_TYPES.each do |id, type| 
      type[:count].times do
        @consumers << Agent.new(type)
      end
    end
    
    # initially, everyone is available
    @providers_available = @providers.dup
    @consumers_available = @consumers.dup
    
  end

  def do_interaction(consumer, provider)
    
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
          # add this interaction as ongoing with full 'life'
          @interactions << { 
            consumer: consumer, 
            provider: provider, 
            life: Parameters::TASK_DURATION 
          }
        end
      end

      # service 'live' interactions
      @interactions.each do |interaction| 

        # every pair with time on the clock consumer might sample, if
        # it does it's perturbed
        # record outcome to file and decrement life
        # cleanup dead interactions
        
        if rand < interaction[:consumer].type[:monitor_prob]
          ob = interaction[:provider].type[:function].call(t)
          noise = interaction[:consumer].type[:noise]/2
          # subjective observation with noise applied
          subj_ob = rand(ob+noise..ob-noise)
        end
        
        interaction[:life] = interaction[:life] - 1
        if interaction[:life] == 0
          @interactions.delete(interaction)
        end
      end
      
    end
  end
  
  data_generator = DataGen.new
  data_generator.generate

end

