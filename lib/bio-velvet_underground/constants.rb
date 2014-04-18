# This constants file is included during the installation make process, and
# so cannot rely on the rest of the bio-velvet_underground code
module Bio
  module Velvet
    class Underground
      DEFAULT_MAXKMERLENGTH=31

      # Different versions of velvet are compiled on installation of bio-velvet_underground.
      # These are the different MAXKMERLENGTH parameters that are given to the velvet Makefile.
      # See the velvet manual for more information on this.
      def self.max_kmers
        [31,63,127,255]
      end

      # Where is the library given the max_kmer_length
      def self.library_location_of(max_kmer_length=nil)
        raise "bad max kmer length #{max_kmer_length}" unless max_kmers.include?(max_kmer_length)

        extras = []
        if !max_kmer_length.nil? and max_kmer_length != DEFAULT_MAXKMERLENGTH
          extras.push "-maxkmer#{max_kmer_length}"
        end
        return File.join(
          File.dirname(__FILE__),
          'bio-velvet_underground',
          'external',
          "libvelvet#{extras.join('')}.so.1.0")
      end
  end
end