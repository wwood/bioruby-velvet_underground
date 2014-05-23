# bio-velvet_underground

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-velvet_underground.png)](http://travis-ci.org/wwood/bioruby-velvet_underground)

This biogem is aimed at providing Ruby bindings to the velvet assembler's source code. See also [bio-velvet](https://github.com/wwood/bioruby-velvet) for Ruby code that does not bind the velvet C.

## Installation

```sh
gem install bio-velvet_underground
```
This can take a few minutes as several versions of velvet with different kmer sizes are compiled.

## Usage

The code is intended to cater for a few specific purposes.

### Running velvet
Running velvet returns a `Result` object, which is effectively a pointer to a velvet result directory
```ruby
require 'bio-velvet_underground'

#kmer 29, '-short my.fasta' the argument to velveth, no special arguments given to velveth.
result = Bio::Velvet::Runner.new.velvet(29,"-short my.fasta",'')
result.result_directory #=> path to temporary directory, containing velvet generated files e.g. contigs.fna

# A pre-defined velvet result directory:
result = Bio::Velvet::Runner.new.velvet(29,"-short my.fasta",'',:output_assembly_path => '/path/to/result')
result.result_directory #=> '/path/to/result'
```
With the magic of Ruby-FFI, the library with the smallest kmer size >= 29 is chosen (in this case 31).
Several libraries are pre-compiled at gem install-time, and then bound at runtime. `velveth` and `velvetg`
steps can be run separetely if required.

### Working with the binary sequence file
The binary sequence file created when velveth is run with the `-create_binary` flag.

```ruby
seqs = Bio::Velvet::Underground::BinarySequenceStore.new '/path/to/velvet/directory/CnyUnifiedSeq'
seqs.length #=> 77 (there is 77 sequences in the CnyUnifiedSeq)
seqs[1] #=> 'CACTTATCTCTACCAAAGATCACGATTTAGAATCAAACTATAAAGTTTTAGAAGATAAAGTAACAACTTATACATGGGGA'
seqs[0] #=> nil (indices map directly to the indices in other velvet files)
```

### Working with LastGraph file
```ruby
path = 'spec/data/3/Assem/LastGraph'
graph = Bio::Velvet::Underground::Graph.parse_from_file path #=> Bio::Velvet::Underground::Graph object

graph.hash_length #=> 31 (kmer length)
graph.node_count #=> 4

graph.nodes[1] #=> Bio::Velvet::Underground::Graph::Node object
graph.nodes[2].ends_of_kmers_of_node #=> 'GTTTAAAAGAAGGAGATTACTTTATAAAA'
graph.nodes[2].coverages #=> [58,0] (coverages from different categories)

graph.nodes[1].short_reads #=> Array of Bio::Velvet::Underground::Graph::NodedRead objects
graph.nodes[1].short_reads[0].direction #=> true (i.e. forward w.r.t the node)
graph.nodes[1].short_reads[2].read_id #=> 4
```
There are more to these objects - see the documention.


Patches to these and other parts of velvet welcome.

## Development practice

The velvet C code 'underground' here is for the most part vanilla velvet code as you might expect.
However some changes were necessary to allow binding from this biogem. For instance the library
does not write to `$stdout` as this interferes with Ruby's writes to `$stdout`.

There are also some extra options for controlling velvet's behaviour, geared towards taking 
some of the guesswork out of the assembly process at the expense of a less resolved `LastGraph`.
These are currently non-standard modifications - get in touch with @wwood if you are interested. 
Not invoking these options should leave 'normal' velvet behaviour intact.

## Project home page

Information on the source tree, documentation, examples, issues and
how to contribute, see

  http://github.com/wwood/bioruby-velvet_underground

The BioRuby community is on IRC server: irc.freenode.org, channel: #bioruby.

## Cite

This software is currently unpublished.

## Biogems.info

This Biogem is published at (http://biogems.info/index.html#bio-velvet_underground)

## Copyright

Copyright (c) 2014 Ben Woodcroft. See LICENSE.txt for further details.

