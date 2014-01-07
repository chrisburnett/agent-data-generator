require_relative 'AgentGraph'
require 'plexus'
include Plexus

class SmallWorldGraph < AgentGraph

  def initialize(params={})
    @beta=params[:beta]||0.2
    @k=params[:k]||6
    @vertices=[]
    super
  end

  def addAgent(v)
    @vertices << v
  end

  #Alg description on wikipedia might be wrong, but this is a good first approximation
  def generateGraph
    vl=[]
    @vertices.each do |v|
      @graph.add_vertex!(v)
      vl << v
    end


    #make the ring
    (0...vl.length).each do |i|
      (1..@k/2).each do |j|
        @graph.add_edge!(vl[i],vl[i-j])
        @graph.add_edge!(vl[i],vl[(i+j)%vl.length])
      end
    end

    #inefficient
    (0...vl.length).each do |i|
      (0...vl.length).each do |j|
        if j<i && @graph.edge?(vl[i],vl[j]) && rand<@beta
          begin
            targ=rand(vl.length)
          end until targ!=i && !@graph.edge?(vl[i],vl[targ])
          @graph.remove_edge!(vl[i],vl[j])
          @graph.add_edge!(vl[i],vl[targ])
        end
      end
    end
    return @graph
  end

end
