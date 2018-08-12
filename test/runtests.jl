using StaticGraphs
using LightGraphs
using LightGraphs.SimpleGraphs
using Test

const testdir = dirname(@__FILE__)

    
@testset "StaticGraphs" begin

    hu = loadgraph(joinpath(testdir, "testdata", "house-uint8.jsg"), SGFormat())
    dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat())

    @testset "staticgraph" begin
        @test sprint(show, StaticGraph(Graph())) == "{0, 0} undirected simple static {UInt8, UInt8} graph"
        g = smallgraph(:house)
        gu = squash(g)
        sg = StaticGraph(g)
        sgu = StaticGraph(gu)
        @test eltype(StaticGraph{UInt128, UInt128}(sgu)) == UInt128
        @test sprint(show, sg) == "{5, 6} undirected simple static {UInt8, UInt8} graph"
        @test sprint(show, sgu) == "{5, 6} undirected simple static {UInt8, UInt8} graph"
        testfn(fn, args...) =
            @inferred(fn(hu, args...)) == 
            @inferred(fn(sg, args...)) == 
            @inferred(fn(sgu, args...)) == 
            fn(g, args...)

        @test hu == sg == sgu
        @test @inferred eltype(hu) == UInt8
        @test testfn(ne)
        @test testfn(nv)
        @test testfn(inneighbors, 1)
        @test testfn(outneighbors, 1)
        @test testfn(vertices)
        @test testfn(degree)
        @test testfn(degree, 1)
        @test testfn(indegree)
        @test testfn(indegree, 1)
        @test testfn(outdegree)
        @test testfn(outdegree, 1)

        @test @inferred has_edge(hu, 1, 3)
        @test @inferred has_edge(hu, 3, 1)
        @test @inferred !has_edge(hu, 2, 3)
        @test @inferred !has_edge(hu, 3, 2)
        @test @inferred !has_edge(hu, 1, 10)
        @test @inferred has_vertex(hu, 1)
        @test @inferred !has_vertex(hu, 10)
        @test @inferred !is_directed(hu)
        @test @inferred !is_directed(StaticGraph)
        @test @inferred collect(edges(hu)) == collect(edges(sg))
    end # staticgraph

    @testset "staticdigraph" begin
        @test sprint(show, StaticDiGraph(DiGraph())) == "{0, 0} directed simple static {UInt8, UInt8} graph"
        dg = PathDiGraph(5)
        dgu = squash(dg)
        dsg = StaticDiGraph(dg)
        dsgu = StaticDiGraph(dgu)
        @test eltype(StaticDiGraph{UInt128, UInt128}(dsgu)) == UInt128
        @test sprint(show, dsg) == "{5, 4} directed simple static {UInt8, UInt8} graph"
        @test sprint(show, dsgu) == "{5, 4} directed simple static {UInt8, UInt8} graph"
        dhu = loadgraph(joinpath(testdir, "testdata", "pathdg-uint8.jsg"), SDGFormat())

        dtestfn(fn, args...) =
            @inferred(fn(dhu, args...)) == 
            @inferred(fn(dsg, args...)) == 
            @inferred(fn(dsgu, args...)) == 
            fn(dg, args...)

        @test dhu == dsg == dsgu
        @test @inferred eltype(dhu) == UInt8
        @test dtestfn(ne)
        @test dtestfn(nv)
        @test dtestfn(inneighbors, 1)
        @test dtestfn(outneighbors, 1)
        @test dtestfn(vertices)
        @test dtestfn(degree)
        @test dtestfn(degree, 1)
        @test dtestfn(indegree)
        @test dtestfn(indegree, 1)
        @test dtestfn(outdegree)
        @test dtestfn(outdegree, 1)

        @test @inferred has_edge(dhu, 1, 2)
        @test @inferred !has_edge(dhu, 2, 1)
        @test @inferred !has_edge(dhu, 1, 10)
        @test @inferred has_vertex(dhu, 1)
        @test @inferred !has_vertex(dhu, 10)
        @test @inferred is_directed(dhu)
        @test @inferred is_directed(StaticDiGraph)
        @test @inferred collect(edges(dhu)) == collect(edges(dsg))
    end # staticdigraph

    @testset "utils" begin
        A = [1:5;]
        B = StaticGraphs.view(A, 2:3)
        @test @inferred B == [2,3]
        B[1] = 5
        @test @inferred A == [1,5,3,4,5]
        A = ["a", "b", "c", "d"]
        @test @inferred StaticGraphs.view(A, 2:3) == ["b", "c"]
    end # utils

    @testset "persistence" begin
        function writegraphs(f, fio)
            @test savegraph(f, hu) == 1
            @test savegraph(f, dhu) == 1
        end
        mktemp(writegraphs)
    end

end # StaticGraphs
