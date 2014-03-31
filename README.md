# bio-velvet_underground

[![Build Status](https://secure.travis-ci.org/wwood/bioruby-velvet_underground.png)](http://travis-ci.org/wwood/bioruby-velvet_underground)

This biogem is aimed at providing Ruby bindings to the velvet assembler's source code.

Note: this software is under active development!

## Installation

```sh
gem install bio-velvet_underground
```

## Usage

The only thing implemented at this stage is access to the binary sequence file created when velveth is run with the `-create_binary` flag.

```ruby
require 'bio-velvet_underground'

seqs = Bio::Velvet::Underground::BinarySequenceStore.new '/path/to/velvet/directory/CnyUnifiedSeq'
seqs[1] #=> 'CACTTATCTCTACCAAAGATCACGATTTAGAATCAAACTATAAAGTTTTAGAAGATAAAGTAACAACTTATACATGGGGA'
seqs.length #=> 77 (there is 77 sequences in the CnyUnifiedSeq)

```

Patches to other parts of velvet welcome.

The API doc is online. For more code examples see the test files in
the source tree.
        
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

