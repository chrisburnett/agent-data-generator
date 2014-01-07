require 'plexus'
include Plexus


class AgentGraph

  attr_accessor :graph

  def initialize(params={})
    @graph=UndirectedGraph.new
  end

  def replaceVertex!(old,new)
    n=@graph.neighborhood(old)
    @graph.remove_vertex!(old)
    @graph.add_vertex!(new)
    n.each do |i|
      @graph.add_edge!(i,new)
    end
  end

  def addAgent(v)
    @graph.add_vertex!(v)
  end

#Testing shows that Plexus (the graph thingie) is slower than a snail sitting on
#top of a dead tortise; this speedup stores all the neighbours of an agent
  def adjCache
    @adjCache=Hash.new
    @graph.each do |a|
      @adjCache[a]=@graph.neighborhood(a)
    end
    return @adjCache
  end

  def write_dot(filename)
    @graph.write_to_graphic_file('png',filename)
  end

  # do nothing for the superclass - some subclasses might need some additional work here
  def generate_graph
  end

end
