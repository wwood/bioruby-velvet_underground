require 'ffi'
require 'pry'

module Bio
  module Velvet
    class Underground
      extend FFI::Library
      ffi_lib File.join(File.dirname(__FILE__),'bio-velvet_underground','external','libvelvet.so.1.0')
    end
  end
end


require 'bio-velvet_underground/binary_sequence_store'
require 'bio-velvet_underground/graph'

if __FILE__ == $0
  binding.pry
end

