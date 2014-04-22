require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

require 'tmpdir'

describe "runner" do
  it "should run basic" do
    reads = File.join TEST_DATA_DIR, '3', 'Sequences'
    Dir.mktmpdir do |dir|
      Bio::Velvet::Underground::Runner.run(51,
      ['-fasta',reads],
      ['-tour_bus','no'],
      {:velvet_directory => dir}).should == 0

      File.exist?(File.join(dir, 'contigs.fa')).should == true
    end
  end
end
