require 'ffi'

require 'bio-velvet_underground/constants'

module Bio
  module Velvet
    class Underground
      extend FFI::Library

      # Return the minimum kmer length greater than or equal to the given
      # graph hash length e.g. 29 => 31, 31 => 31, 33 => 63.
      def self.compilation_max_kmer(graph_hash_length)
        max_kmers.select{|k| given_kmer<=k}.min
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
        $stderr.puts "Found max kmer length #{max_kmer_length} to load with the velvet library"

        # Set the ffi library path to the correct velvet one
        lib_location = self.library_location_of(max_kmer_length)
        $stderr.puts "Loading velvet underground FFI library #{lib_location}.."
        ffi_lib lib_location
        $stderr.puts "Velvet library loaded."
      end
    end
  end
end


require 'bio-velvet_underground/binary_sequence_store'
require 'bio-velvet_underground/graph'

