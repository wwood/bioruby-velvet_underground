#(c) Copyright 2011 Raoul Bonnal. All Rights Reserved. Modified by Ben Woodcroft, 2014

# create Rakefile for shared library compilation



path = File.expand_path(File.dirname(__FILE__))

path_external = File.join(path, "../lib/bio-velvet_underground/external")

version = File.open(File.join(path_external,"VERSION"),'r')
Version = version.read
version.close

File.open(File.join(path,"Rakefile"),"w") do |rakefile|
rakefile.write <<-RAKE
require 'rbconfig'
require 'fileutils'
include FileUtils::Verbose
require 'rake/clean'

path = File.expand_path(File.dirname(__FILE__))
path_external = File.join(File.dirname(__FILE__), "../lib/bio-velvet_underground/external")

# Require constants - code shared between before and after installation
require File.join(File.dirname(__FILE__), "../lib/bio-velvet_underground/constants")

task :compile do
  cd(File.join(File.dirname(__FILE__),'src')) do
    sh "patch -p1 < ../bioruby.patch"
    case Config::CONFIG['host_os']
      when /linux/

        # Create library with default install params
        $stdout.puts "Making velvet shared library with default parameters"
        sh "make shared"
        shared_location = 'obj/shared'
        cp(File.join(shared_location,"libvelvet.so.1.0"), path_external)
        $stdout.puts "Finished installing default library version"
        # Create libraries with larger non-default kmer sizes
        Bio::Velvet::Underground.max_kmers.each do |max_kmer|
          next if max_kmer == Bio::Velvet::Underground::DEFAULT_MAXKMERLENGTH

          $stdout.puts "Making velvet shared library with kmer "+max_kmer.to_s
          library_name = File.basename Bio::Velvet::Underground.library_location_of(max_kmer)
          sh "make clean; make MAXKMERLENGTH="+max_kmer.to_s+" shared"
          cp(File.join(shared_location,"libvelvet.so.1.0"),
          File.join(path_external,File.basename(library_name)))
        end

      when /darwin/
        raise NotImplementedError, "possibly will work, but bio-velvet_underground is not tested on OSX"
      when /mswin|mingw/ then raise NotImplementedError, "bio-velvet_underground library is not available for Windows platform"
    end #case
  end #cd
end

task :clean do
  cd(File.join(path,'src')) do
    sh "make clean"
  end
  rm(File.join(path_external,"libvelvet.so.1.0"))
end

task :default => [:compile]

RAKE

end
