module Parameters

  # use this with TASK_DURATION to get dynamic durations
  # def self.get_duration
  #   # some function here
  # end

  TIME_STEPS = 1000

  # probability of a free consumer interacting in any timestep
  INTERACTION_PROBABILITY = 0.3
  
  # making this a constant for now, but it could easily be a function
  # for another lovely degree of uncertainty
  # TASK_DURATION = self.get_duration
  TASK_DURATION = 10
  
  # noise determines how much each sample will be perturbed either up
  # or down (maximally)
  PROVIDER_TYPES = [
    { class: :sawtooth, function: -> (t) { t - t.floor }, noise: 0, count: 50 },
    { class: :sine, function: -> (t) { Math.sin(t)}, noise: 0, count: 50 },
    { class: :random, function: -> (t) { rand >= 0.5 ? 1 : 0 }, noise: 0, count: 10 }
  ]
  
  # Monitor_prob determines how likely observations will be made
  # during the delegation. Noise value determines by how much each
  # value will be maximally perturbed either up or down.
  CONSUMER_TYPES = [
    { class: :vigilant, monitor_prob: 0.95, noise: 0.1, count: 25 },
    { class: :negligent, monitor_prob: 0.2, noise: 0.4, count: 25 },
    { class: :mediocre, monitor_prob: 0.5, noise: 0.2, count: 25 }
  ]
  
end
