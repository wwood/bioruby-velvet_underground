class Bio::Velvet::Underground
  class BinarySequenceStore
    # Parse a CnyUnifiedSeq file in so that sequences can be accessed
    def initialize(cny_unified_seq_file)
      readset_pointer = Bio::Velvet::Underground.importCnyReadSet cny_unified_seq_file
      @readset = Bio::Velvet::Underground::ReadSet.new(readset_pointer)
    end

    # Return a sequence from the store given its read ID.
    def [](sequence_id)
      if sequence_id==0 or sequence_id > @readset[:readCount]
        raise "Invalid sequence_id #{sequence_id}"
      end

      pointer = Bio::Velvet::Underground.getTightStringInArray(
        @readset[:tSequences], sequence_id-1
        )
      Bio::Velvet::Underground.readTightString pointer
    end

    # Number of sequences in this store
    def length
      @readset[:readCount]
    end
  end

  private
  # struct readSet_st {
  #  char **sequences;
  #  TightString *tSequences;
  #  char **labels;
  #  char *tSeqMem;
  #  Quality **confidenceScores;
  #  Probability **kmerProbabilities;
  #  IDnum *mateReads;
  #  Category *categories;
  #  unsigned char *secondInPair;
  #  IDnum readCount;
  # };
  class ReadSet < FFI::Struct
    layout :sequences, :pointer, # char **sequences;
    :tSequences, :pointer, # TightString *tSequences;
    :labels, :pointer, # char **labels;
    :tSeqMem, :pointer, # char *tSeqMem; #TODO: they don't really mean char* here - meant as an unsigned short?
    :confidenceScores, :pointer, # Quality **confidenceScores;
    :kmerProbabilities, :pointer, # Probability **kmerProbabilities;
    :mateReads, :pointer, # IDnum *mateReads;
    :categories, :pointer, # Category *categories;
    :secondInPair, :pointer, # unsigned char *secondInPair;
    :readCount, :int32 # IDnum readCount;
  end

  # ReadSet *importCnyReadSet(char *filename);
  attach_function :importCnyReadSet, [:string], :pointer

  # char *readTightString(TightString * tString); #tightString.h
  attach_function :readTightString, [:pointer], :string

  # TightString *getTightStringInArray(TightString * tString,
  #			   IDnum	 position);
  attach_function :getTightStringInArray, [:pointer, :int32], :pointer
end