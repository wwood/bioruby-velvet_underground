require File.expand_path(File.dirname(__FILE__) + '/spec_helper')

describe "binary sequence store" do
  it "should be able to load sequences" do
    path = File.join TEST_DATA_DIR, '1', 'CnyUnifiedSeq'
    seqs = Bio::Velvet::Underground::BinarySequenceStore.new path
    seqs[1].should == 'CACTTATCTCTACCAAAGATCACGATTTAGAATCAAACTATAAAGTTTTAGAAGATAAAGTAACAACTTATACATGGGGA'
    seqs[77].should == 'CCTGTACCTGGAAGTGAAATACCAGCATAGTTTTTAATTTGTACATTAAATAATACATTGCCATCATTCATAGTAATATTATTTATTATACTTCCAGCTTCATTGCCATTAGTTACAGATATAGTTGCTTGACCAGTATACTCTCCATTATCATCTTTTTGAGCTGTTATAGTAACTTTTACTGGTTCTTTTAAAAGGCTATACCCTTTAGGAGCTTTTTCTTCTTTTATAAAGTAATCTCCTTCTTTTAAACCAGTAAATATAACTCGTCCATTTTTATCAGTTACACCCTTTCCTTTTAATAAAACCACATTTCCAGTAGAATCATACGTATATTTACCAATTACAT'
  end

  it "should be #length" do
    path = File.join TEST_DATA_DIR, '1', 'CnyUnifiedSeq'
    seqs = Bio::Velvet::Underground::BinarySequenceStore.new path
    seqs.length.should == 77
  end

  it 'should respect array boundaries' do
    path = File.join TEST_DATA_DIR, '1', 'CnyUnifiedSeq'
    seqs = Bio::Velvet::Underground::BinarySequenceStore.new path
    expect {
      seqs[0]
      }.to raise_error
    expect {
      seqs[78]
      }.to raise_error
  end

  it 'should be able to understand mates' do
    path = File.join TEST_DATA_DIR, '2', 'CnyUnifiedSeq'
    seqs = Bio::Velvet::Underground::BinarySequenceStore.new path
    seqs.is_second_in_pair?(1).should == false
    seqs.is_second_in_pair?(2).should == true
    seqs.is_second_in_pair?(5).should == false
    seqs.pair_id(1).should == 2
    seqs.pair_id(2).should == 1
    seqs.pair_id(5).should == 6
    seqs.pair_id(6).should == 5
  end

  it 'should be able to understand non-mates and mates in the same run' do
    path = File.join TEST_DATA_DIR, '5_singles_and_pairs', 'CnyUnifiedSeq'
    seqs = Bio::Velvet::Underground::BinarySequenceStore.new path
    seqs.pair_id(1).should == nil
    seqs.pair_id(50000).should == nil
    seqs.pair_id(50001).should == 50002
    seqs.pair_id(100000).should == 99999
  end
end
