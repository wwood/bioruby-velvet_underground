class Bio::Velvet::Underground
  #TODO: this class is under construction
  class Runner
    # Run velveth and velvetg, selecting the most memory efficient library for the purpose
    #
    # kmer size: (integer)
    # velvet_directory: where to run velvet
    # velveth_options_string: Array of string options to velveth as on the cmdline, excluding the directory and kmer
    # velvetg_options_string: Array of string options to velveth as on the cmdline, excluding the directory
    # options: other options:
    # :velvet_directory: where to run the velvets. Required (currently).
    def self.run(kmer, velveth_options, velvetg_options=[], options={})
      #load library with appropriate kmer size
      Bio::Velvet::Underground.attach_shared_library(:kmer => kmer)

      velvet_directory = options[:velvet_directory]
      raise "Need options[:velvet_directory] to run velvet" if velvet_directory.nil?

      # velveth
      # Can't just pass a regular Ruby array of strings, as explained at
      # http://zegoggl.es/2009/05/ruby-ffi-recipes.html
      velveth_array_of_strings = []
      velveth_array_of_strings << FFI::MemoryPointer.from_string('velveth')
      velveth_array_of_strings << FFI::MemoryPointer.from_string(velvet_directory)
      velveth_array_of_strings << FFI::MemoryPointer.from_string(kmer.to_s)
      velveth_options.each do |o|
        velveth_array_of_strings << FFI::MemoryPointer.from_string(o)
      end
      velveth_array_of_strings << nil
      p velveth_array_of_strings
      argv = FFI::MemoryPointer.new(:pointer, velveth_array_of_strings.length)
      velveth_array_of_strings.each_with_index do |p, i|
        argv[i].put_pointer(0,  p)
      end
      returned = Bio::Velvet::Underground.velveth velveth_array_of_strings.length-1, argv
      raise "Error running velveth (#{returned})" unless returned == 0

      # velvetg
      velvetg_array_of_strings = []
      velvetg_array_of_strings << FFI::MemoryPointer.from_string('velvetg')
      velvetg_array_of_strings << FFI::MemoryPointer.from_string(velvet_directory)
      velvetg_options.each do |o|
        velvetg_array_of_strings << FFI::MemoryPointer.from_string(o)
      end
      velvetg_array_of_strings << nil
      argv = FFI::MemoryPointer.new(:pointer, velvetg_array_of_strings.length)
      velvetg_array_of_strings.each_with_index do |p, i|
        argv[i].put_pointer(0,  p)
      end
      returned = Bio::Velvet::Underground.velvetg velvetg_array_of_strings.length-1, argv
      raise "Error running velvetg (#{returned})" unless returned == 0

      return 0
    end
  end

  def self.attach_runner_functions
    #TODO: fix these functions by modifying the input source code
    attach_function :velveth, [:int32, :pointer], :int32
    attach_function :velvetg, [:int32, :pointer], :int32
  end
end