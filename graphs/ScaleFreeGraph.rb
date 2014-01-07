require 'plexus'
require_relative 'AgentGraph'
include Plexus

class ScaleFreeGraph < AgentGraph

  def initialize(params={})
    @m=params[:m]||2
    super
  end

  def generateGraph
    return @graph
  end

  def addAgent(v)
    if @graph.size==0
      @graph.add_vertex!(v)
      return
    end
    #while we don't have enough vertices in the graph, we link them all together
    if @graph.size<=@m
      @graph.add_vertex!(v)
      @graph.each do |u|
        if u!=v
          @graph.add_edge!(u,v)
        end
      end
      return @graph
    end

    @graph.add_vertex!(v)

    tot=0
    @graph.each do |u|
      if !u.equal?(v)
        tot=tot+@graph.neighborhood(u).length
      end
    end

    con=@graph.remove_vertex(v).vertices

    (0...@m).each do |i|
      r=rand(tot)
      sum=0
      con.each do |u|
        sum=sum+@graph.neighborhood(u).length
        if r<=sum
          tot=tot-@graph.neighborhood(u).length
          @graph.add_edge!(u,v)
          con.delete(u)
          break
        end
      end
    end

    return @graph
  end

end
