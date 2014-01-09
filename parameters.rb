module Parameters

  TIME_STEPS = 1000
  INTERACTION_PROBABILITY = 0.8
  
  # noise determines how much each sample will be perturbed either up
  # or down (maximally)

  PROVIDER_TYPES = {
    sawtooth: { function: -> (t) { t - t.floor }, noise: 0, count: 50 },
    sine: { function: -> (t) { Math.sin(t)}, noise: 0, count: 50 }
  }
  
  # Monitor_freq determines how many observations will be made during
  # the delegation. Accuracy value determines by how much each value
  # will be maximally perturbed either up or down.

  CONSUMER_TYPES = {
    vigilant: { monitor_freq: 10, accuracy: 0.2, count: 25 },
    negligent: { monitor_freq: 2, accuracy: 1, count: 25 },
    mediocre: { monitor_freq: 5, accuracy: 0.8, count: 25 }
  }
  
    
  
  
end
