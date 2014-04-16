class Bio::Velvet::Underground
  class Graph
    attr_accessor :internal_graph_struct

    # Use parse_from_file, not #new
    def initialize(graph_struct)
      @internal_graph_struct = graph_struct
    end

    # Read in a graph from a file
    def self.parse_from_file(path)
      pointer = Bio::Velvet::Underground.importGraph path
      struct = Bio::Velvet::Underground::GraphStruct.new pointer
      Graph.new struct
    end

    def nodes
      NodeArray.new @internal_graph_struct
    end

    class NodeArray
      def initialize(graph_struct)
        @internal_graph_struct = graph_struct
      end

      def length
        Bio::Velvet::Underground.nodeCount @internal_graph_struct
      end

      def [](node_id)
        pointer = Bio::Velvet::Underground.getNodeInGraph @internal_graph_struct, node_id
        node_struct = Bio::Velvet::Underground::NodeStruct.new pointer
        Node.new(@internal_graph_struct, node_struct)
      end
    end

    class Node
      def initialize(graph_struct, node_struct)
        @internal_graph_struct = graph_struct
        @internal_node_struct = node_struct
      end

      def node_id
        @internal_node_struct[:ID]
      end

      def short_reads
        array_start_pointer = Bio::Velvet::Underground.getNodeReads @internal_node_struct, @internal_graph_struct
        num_short_reads = Bio::Velvet::Underground.getNodeReadCount @internal_node_struct, @internal_graph_struct
        short_reads = (0...num_short_reads).collect do |i|
          # Use the fact that FFI pointers can do pointer arithmetic
          pointer = array_start_pointer+i
          NodedRead.new @internal_graph_struct, Bio::Velvet::Underground::ShortReadMarker.new(pointer)
        end
        return short_reads
      end
    end

    class ArcArray
      def initialize(graph_struct)
        @internal_graph_struct = graph_struct
      end

      def get_arcs_by_node_id(node_id1, node_id2=nil)
      end
    end

    class NodedRead
      def initialize(short_read_struct)
        @internal_short_read_struct = short_read_struct
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

      def direction
        raise
      end
    end
  end


  private
  class GraphStruct < FFI::Struct
    #class struct graph_st {
    layout :nodes, :pointer, # Node **nodes;
    :arcLookupTable, :pointer, # Arc **arcLookupTable;
    :nodeReads, :pointer, # ShortReadMarker **nodeReads;
    :nodeReadCounts, :int32, # IDnum *nodeReadCounts;
    :gapMarkers, :pointer, # GapMarker **gapMarkers;
    :insertLengths, :pointer, # Coordinate insertLengths[CATEGORIES + 1];
    :insertLengths_var, :pointer, # double insertLengths_var[CATEGORIES + 1];
    :sequenceCount, :int32, # IDnum sequenceCount;
    :nodeCount, :int32, # IDnum nodeCount;
    :wordLength, :int, # int wordLength;
    :double_stranded, :bool # boolean double_stranded;
  end

  class NodeStruct < FFI::Struct
    #     struct node_st {
    layout :twinNode, :pointer, # 	Node *twinNode;		// 64
    :arc, :pointer, # 	Arc *arc;		// 64
    :descriptor, :pointer, # 	Descriptor *descriptor;	// 64
    :marker, :pointer, # 	PassageMarkerI marker;	// 32
    :length, :int32, # 	IDnum length;	// 32
    :virtualCoverage, :int32, #   	IDnum virtualCoverage;	// 32 * 2
    :ID, :int32, # 	IDnum ID;		// 32
    :arcCount, :int32, # 	IDnum arcCount;		// 32
    :status, :bool, # 	boolean status;		// 1
    :uniqueness, :bool# 	boolean uniqueness;	// 1
  end

  class ArcStruct < FFI::Struct
    # struct arc_st {
    layout :twinArc, :pointer, # 	Arc *twinArc;		// 64
    :next, :pointer, # 	Arc *next;		// 64
    :previous, :pointer, # 	Arc *previous;		// 64
    :nextInLookupTable, :pointer, # 	Arc *nextInLookupTable;	// 64
    :destination, :pointer, # 	Node *destination;	// 64
    :multiplicity, :int32 # 	IDnum multiplicity;	// 32
    # }
  end

  class ShortReadMarker < FFI::Struct
    # struct shortReadMarker_st {
    layout :position, :int32, # 	IDnum position;
    :readID, :int32, # 	IDnum readID;
    :offset, :int32 # 	ShortLength offset;
    # } ATTRIBUTE_PACKED;
  end

  attach_function :importGraph, [:string], :pointer
  attach_function :nodeCount, [:pointer], :int32
  # Arc *getArcBetweenNodes(Node * originNode, Node * destinationNode,
  # Graph * graph)
  attach_function :getArcBetweenNodes, [:pointer, :pointer, :pointer], :pointer

  # Nucleotide getNucleotideInNode(Node * node, Coordinate index) {
  # IDnum getNodeID(Node * node)
  # Node *getNodeInGraph(Graph * graph, IDnum nodeID)
  attach_function :getNodeInGraph, [:pointer, :int32], :pointer

  # ShortReadMarker *getNodeReads(Node * node, Graph * graph);
  attach_function :getNodeReads, [:pointer, :pointer], :pointer
  # IDnum getNodeReadCount(Node * node, Graph * graph);
  attach_function :getNodeReadCount, [:pointer, :pointer], :int32
end
