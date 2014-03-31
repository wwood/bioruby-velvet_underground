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
end
