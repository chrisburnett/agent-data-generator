require_relative 'parameters'
require_relative 'consumer'
require_relative 'provider'

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
        @providers << Provider.new(type)
      end
    end

    Parameters::CONSUMER_TYPES.each do |id, type| 
      type[:count].times do
        @consumers << Consumer.new(type)
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
          do_interaction(consumer, provider)
        end
      end
      
    end
  end
  
  data_generator = DataGen.new
  data_generator.generate

end
