require 'ffi'
require 'pry'

module Bio
  module Velvet
    class Underground
  extend FFI::Library
  ffi_lib '/home/ben/git/velvet/obj/velvet.so.1.0.1'

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
    :tight_string, :pointer, # TightString *tSequences;
    :labels, :pointer, # char **labels;
    :t_seq_mem, :pointer, # char *tSeqMem; #TODO: they don't really mean char* here - meant as an unsigned short?
    :quality, :pointer, # Quality **confidenceScores;
    :pobability, :pointer, # Probability **kmerProbabilities;
    :id_num, :pointer, # IDnum *mateReads;
    :categories, :pointer, # Category *categories;
    :second_in_pair, :pointer, # unsigned char *secondInPair;
    :read_count, :int32 # IDnum readCount;
  end

  class SequencesInPointers < FFI::Struct
    layout :sequence, :pointer
  end

  class SequenceInArray < FFI::Struct
    layout :seq, :string
  end

  # ReadSet *importCnyReadSet(char *filename);
  attach_function :importCnyReadSet, [:string], :pointer

  #void getCnySeqNucl(SequencesReader *seqReadInfo, uint8_t *sequence);
  attach_function :getCnySeqNucl, [:pointer, :pointer], :void

  # void convertSequences(ReadSet * rs)
  attach_function :convertSequences, [:pointer], :void

  # char *readTightString(TightString * tString); #tightString.h
  attach_function :readTightString, [:pointer], :string

  # TightString *getTightStringInArray(TightString * tString,
	#			   IDnum	 position);
  attach_function :getTightStringInArray, [:pointer, :int32], :pointer
end
  end
end

module Libc
  extend FFI::Library
  ffi_lib FFI::Library::LIBC

  attach_function :strlen, [:string], :int32
end

seqs = Bio::Velvet::Underground.importCnyReadSet('velv/CnyUnifiedSeq')
readset= Bio::Velvet::Underground::ReadSet.new(seqs)
puts "Found #{readset[:read_count]} reads from velvet underground"

puts Bio::Velvet::Underground.readTightString(readset[:tight_string])

puts Bio::Velvet::Underground.readTightString Bio::Velvet::Underground.getTightStringInArray(readset[:tight_string],0)
  puts Bio::Velvet::Underground.readTightString Bio::Velvet::Underground.getTightStringInArray(readset[:tight_string],1)
  puts Bio::Velvet::Underground.readTightString Bio::Velvet::Underground.getTightStringInArray(readset[:tight_string],2)

binding.pry
