require 'csv'

class Bio::Velvet::Underground

  class Graph
    attr_accessor :internal_graph_struct

    # Use parse_from_file, not #new
    def initialize(graph_struct)
      @internal_graph_struct = graph_struct
    end

    # Read in a graph from a file
    def self.parse_from_file(path)
      # First read the first line of the file to determine which library to load
      hash_length = nil
      CSV.foreach(path, :col_sep => "\t") do |row|
        raise "Badly formatted graph file" if row.length < 3
        hash_length = row[2].to_i
        if hash_length < 1 or hash_length > Bio::Velvet::Underground.max_kmers.max
          raise "unable to load velvet shared library for kmer length `#{hash_length}'"
        end
        break
      end
      raise "No lines in graph file `#{path}', is it really a velvet LastGraph-type file?" if hash_length.nil?

      # setup FFI in the underground base class with the correct kmer length
      Bio::Velvet::Underground.attach_shared_library(:kmer => hash_length)

      # Using the loaded velvet library, do the actual import of the graph
      pointer = Bio::Velvet::Underground.importGraph path
      struct = Bio::Velvet::Underground::GraphStruct.new pointer
      Graph.new struct
    end

    def nodes
      NodeArray.new self
    end

    def node_count
      @internal_graph_struct[:nodeCount]
    end

    def hash_length
      @internal_graph_struct[:wordLength]
    end


    class NodeArray
      def initialize(graph)
        @graph = graph
      end

      def length
        Bio::Velvet::Underground.nodeCount @graph.internal_graph_struct
      end

      def [](node_id)
        return nil if node_id < 1 or node_id > @graph.internal_graph_struct[:nodeCount]
        pointer = Bio::Velvet::Underground.getNodeInGraph @graph.internal_graph_struct, node_id
        node_struct = Bio::Velvet::Underground::NodeStruct.new pointer
        Node.new(@graph, node_struct)
      end
    end

    class Node
      attr_accessor :internal_node_struct

      def initialize(graph, node_struct)
        @graph = graph
        @internal_node_struct = node_struct
      end

      def node_id
        @internal_node_struct[:ID]
      end

      def length_alone
        @internal_node_struct[:length]
      end

      def coverages
        [
          @internal_node_struct[:virtualCoverage1],
          @internal_node_struct[:virtualCoverage2],
          ]
      end

      def ends_of_kmers_of_node
        seq = []
        key = %w(A C G T)
        0.upto(length_alone-1) do |i|
          n = Bio::Velvet::Underground.getNucleotideInNode(@internal_node_struct, i)
          seq.push key[n]
        end
        return seq.join
      end

      def ends_of_kmers_of_twin_node
        twin.ends_of_kmers_of_node
      end

      def twin
        return @twin unless @twin.nil?

        twin_pointer = Bio::Velvet::Underground.getTwinNode(@internal_node_struct)
        @twin = Bio::Velvet::Underground::Graph::Node.new(
          @graph,
          Bio::Velvet::Underground::NodeStruct.new(twin_pointer)
          )
      end

      def fwd_short_reads
        array_start_pointer = Bio::Velvet::Underground.getNodeReads @internal_node_struct, @graph.internal_graph_struct
        num_short_reads = Bio::Velvet::Underground.getNodeReadCount @internal_node_struct, @graph.internal_graph_struct
        short_reads = (0...num_short_reads).collect do |i|
          # Use the fact that FFI pointers can do pointer arithmetic
          pointer = array_start_pointer+(i*Bio::Velvet::Underground::ShortReadMarker.size)
          NodedRead.new Bio::Velvet::Underground::ShortReadMarker.new(pointer), true
        end
        return short_reads
      end

      def rev_short_reads
        twin.fwd_short_reads
      end

      def short_reads
        reads = fwd_short_reads
        rev_short_reads.each do |read|
          read.direction = false
          reads.push read
        end
        return reads
      end

    end

    class ArcArray
      def initialize(graph_struct)
        @internal_graph_struct = graph_struct
      end

      def get_arcs_by_node_id(node_id1, node_id2=nil)
        raise
      end
    end

    class NodedRead
      attr_accessor :direction

      def initialize(short_read_struct, direction)
        @internal_short_read_struct = short_read_struct
        @direction = direction
      end

      def read_id
        @internal_short_read_struct[:readID]
      end

      def offset_from_start_of_node
        @internal_short_read_struct[:offset]
      end

      def start_coord
        @internal_short_read_struct[:position]
      end
    end
  end


  private
  class GraphStruct < FFI::Struct
    #class struct graph_st {
    layout :nodes, :pointer, # Node **nodes;
    :arcLookupTable, :pointer, # Arc **arcLookupTable;
    :nodeReads, :pointer, # ShortReadMarker **nodeReads;
    :nodeReadCounts, :pointer, # IDnum *nodeReadCounts;
    :gapMarkers, :pointer, # GapMarker **gapMarkers;
    #TODO: here default compilation settins are assumed (CATEGORIES=2) - probably not a future-proof assumption
    :insertLengths0, :int64, # Coordinate insertLengths[CATEGORIES + 1];
    :insertLengths1, :int64, # Coordinate insertLengths[CATEGORIES + 1];
    :insertLengths2, :int64, # Coordinate insertLengths[CATEGORIES + 1];
    :insertLengths_var0, :pointer, # double insertLengths_var[CATEGORIES + 1];
    :insertLengths_var1, :pointer, # double insertLengths_var[CATEGORIES + 1];
    :insertLengths_var2, :pointer, # double insertLengths_var[CATEGORIES + 1];
    :sequenceCount, :int32, # IDnum sequenceCount;
    :nodeCount, :int32, # IDnum nodeCount;
    :wordLength, :int, # int wordLength;
    :double_stranded, :bool # boolean double_stranded;
  end

  class NodeStruct < FFI::Struct
    pack 1  # pack all members on a 1 byte boundary
    #     struct node_st {
    layout :twinNode, :pointer, # 	Node *twinNode;		// 64
    :arc, :pointer, # 	Arc *arc;		// 64
    :descriptor, :pointer, # 	Descriptor *descriptor;	// 64
    :marker, :uint32, # 	PassageMarkerI marker;	// 32
    :length, :int32, # 	IDnum length;	// 32
    :virtualCoverage1, :int32, # IDnum virtualCoverage[CATEGORIES];	// 32 * 2
    :virtualCoverage2, :int32,
	  :originalVirtualCoverage1, :int32, # IDnum originalVirtualCoverage[CATEGORIES];	// 32 * 2
	  :originalVirtualCoverage2, :int32,
    :ID, :int32, # 	IDnum ID;		// 32
    :arcCount, :int32, # 	IDnum arcCount;		// 32
    :status, :int8, # 	boolean status;		// 1
    :uniqueness, :int8 # 	boolean uniqueness;	// 1
    #} ATTRIBUTE_PACKED;
  end

  class ArcStruct < FFI::Struct
    pack 1  # pack all members on a 1 byte boundary
    # struct arc_st {
    layout :twinArc, :pointer, # 	Arc *twinArc;		// 64
    :next, :pointer, # 	Arc *next;		// 64
    :previous, :pointer, # 	Arc *previous;		// 64
    :nextInLookupTable, :pointer, # 	Arc *nextInLookupTable;	// 64
    :destination, :pointer, # 	Node *destination;	// 64
    :multiplicity, :int32 # 	IDnum multiplicity;	// 32
    # } ATTRIBUTE_PACKED;
  end

  class ShortReadMarker < FFI::Struct
    pack 1  # pack all members on a 1 byte boundary
    # struct shortReadMarker_st {
    layout :position, :int32, # 	IDnum position;
    :readID, :int32, # 	IDnum readID;
    :offset, :int16 # 	ShortLength offset;
    # } ATTRIBUTE_PACKED;
  end

  def self.attach_graph_functions
    attach_function :importGraph, [:string], :pointer
    attach_function :nodeCount, [:pointer], :int32
    # Arc *getArcBetweenNodes(Node * originNode, Node * destinationNode,
    # Graph * graph)
    attach_function :getArcBetweenNodes, [:pointer, :pointer, :pointer], :pointer

    # Nucleotide getNucleotideInNode(Node * node, Coordinate index) {
    attach_function :getNucleotideInNode, [:pointer, :int32], :char
    # IDnum getNodeID(Node * node)
    # Node *getNodeInGraph(Graph * graph, IDnum nodeID)
    attach_function :getNodeInGraph, [:pointer, :int32], :pointer
    # Node *getTwinNode(Node * node);
    attach_function :getTwinNode, [:pointer], :pointer

    # ShortReadMarker *getNodeReads(Node * node, Graph * graph);
    attach_function :getNodeReads, [:pointer, :pointer], :pointer
    # IDnum getNodeReadCount(Node * node, Graph * graph);
    attach_function :getNodeReadCount, [:pointer, :pointer], :int32
  end
end
