require 'ffi'

require 'bio-velvet_underground/constants'
require 'bio-logger'

Bio::Log::LoggerPlus.new('bio-velvet_underground')
module Bio
  module Velvet
    module UndergroundLogging
      def log
        Bio::Log::LoggerPlus['bio-velvet_underground']
      end
    end

    class Underground
      extend FFI::Library
      include Bio::Velvet::UndergroundLogging
      def self.log
        Bio::Log::LoggerPlus['bio-velvet_underground']
      end

      # Return the minimum kmer length greater than or equal to the given
      # graph hash length e.g. 29 => 31, 31 => 31, 33 => 63.
      def self.compilation_max_kmer(graph_hash_length)
        max_kmers.select{|k| graph_hash_length<=k}.min
      end

      # Attach the correct shared velvet library with ffi. Options:
      # :kmer: attach library with at least this much kmer length
      def self.attach_shared_library(velvet_compilation_options={})
        max_kmer_length = nil
        given_kmer = velvet_compilation_options[:kmer]
        if !given_kmer.nil?
          max_kmer_length = compilation_max_kmer(given_kmer)
          raise "No installed velvet library available for max kmer #{given_kmer}" if max_kmer_length.nil?
        end
        log.debug "Found max kmer length #{max_kmer_length} to load with the velvet library"

        # Set the ffi library path to the correct velvet one
        lib_location = self.library_location_of(max_kmer_length)
        log.debug "Loading velvet underground FFI library #{lib_location}.."
        ffi_lib lib_location
        log.debug "Velvet library loaded."

        attach_graph_functions
        attach_binary_sequence_functions
      end
    end
  end
end

require 'bio-velvet_underground/binary_sequence_store'
require 'bio-velvet_underground/graph'

