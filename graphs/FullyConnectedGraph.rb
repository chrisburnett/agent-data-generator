require_relative 'AgentGraph'
require 'plexus'
include Plexus

class FullyConnectedGraph < AgentGraph

  def initialize(params={})
    super
  end

  def generateGraph
    return @graph
  end

  def addAgent(v)
    @graph.add_vertex!(v)
    @graph.each do |u|
      if !u.equal?(v)
        @graph.add_edge!(u,v)
      end
    end
    return @graph
  end

end
