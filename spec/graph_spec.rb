require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "graph" do
  it "should be able to load a graph and respond to basic structures" do
    path = File.join TEST_DATA_DIR, '3', 'Assem', 'LastGraph'
    graph = Bio::Velvet::Underground::Graph.parse_from_file path

    graph.hash_length.should == 31
    graph.node_count.should == 4
  end

  describe "nodes" do
    it "should provide basic info" do
      path = File.join TEST_DATA_DIR, '3', 'Assem', 'LastGraph'
      graph = Bio::Velvet::Underground::Graph.parse_from_file path

      graph.nodes[1].kind_of?(Bio::Velvet::Underground::Graph::Node).should == true
      graph.nodes[1].length_alone.should == 228
      graph.nodes[1].node_id.should == 1
      graph.nodes[2].kind_of?(Bio::Velvet::Underground::Graph::Node).should == true
      graph.nodes[2].node_id.should == 2
      graph.nodes[2].length_alone.should == 29
      graph.nodes[3].length_alone.should == 224
      graph.nodes[4].length_alone.should == 38
      graph.nodes[4].node_id.should == 4
      graph.nodes[2].coverages.should == [58,0]

      graph.nodes[2].ends_of_kmers_of_node.should == 'GTTTAAAAGAAGGAGATTACTTTATAAAA'
      graph.nodes[2].ends_of_kmers_of_twin_node.should == 'AGTAAATATAACTCGTCCATTTTTATCAG'
    end

    it 'should work with short reads' do
      path = File.join TEST_DATA_DIR, '3', 'Assem', 'LastGraph'
      graph = Bio::Velvet::Underground::Graph.parse_from_file path

      node = graph.nodes[1]
      shorts = node.short_reads
      shorts.length.should == 5
      shorts.collect{|s| s.direction}.should == [true, true, true, false, false]
      shorts.collect{|s| s.read_id}.should == [1,2,4,3,5]
      shorts.collect{|s| s.offset_from_start_of_node}.should == [0,0,0,0,0]
      shorts.collect{|s| s.start_coord}.should == [0,0,0,253,262]
    end
  end
end
