module Parameters

  TIME_STEPS = 1000
  INTERACTION_PROBABILITY = 0.8
  
  # making this a constant for now, but it could easily be a function
  # for another lovely degree of uncertainty
  TASK_DURATION = 10
  
  # noise determines how much each sample will be perturbed either up
  # or down (maximally)

  PROVIDER_TYPES = {
    sawtooth: { function: -> (t) { t - t.floor }, noise: 0, count: 50 },
    sine: { function: -> (t) { Math.sin(t)}, noise: 0, count: 50 }
  }
  
  # Monitor_prob determines how likely observations will be made
  # during the delegation. Noise value determines by how much each
  # value will be maximally perturbed either up or down.

  CONSUMER_TYPES = {
    vigilant: { monitor_prob: 0.95, noise: 0.1, count: 25 },
    negligent: { monitor_prob: 0.2, noise: 0.4, count: 25 },
    mediocre: { monitor_prob: 0.5, noise: 0.2, count: 25 }
  }
  
    
  
  
end
