require 'column'
describe Column do
  before :each do
    @col = Column.new
    @col.relname = 'r1'
    @col.colname = 'c1'
    @col2 = Column.new
    @col2.relname = 'r2'
    @col2.colname = 'c2'
    @col3 = Column.new
    @col3.relname = 'r1'
    @col3.colname = 'c1'
  end
  describe '#new' do
    it 'returns a Column object' do
      expect(@col).to be_an_instance_of Column
    end
  end
  # describe "!=" do
  # 	context "given a column of different relname and colname" do
  # 		it "should returns true" do
  # 			expect (@co1!= @col2).to be true
  # 		end
  # 	end
  # 	# context "given a column of same relname and colname" do
  # 	# 	it "should returns false" do
  # 	# 		expect(@co1!= @col3).to be false
  # 	# 	end
  # 	# end
  # end
  describe '==' do
    context 'given a column of different relname and colname' do
      it 'should returns false' do
        expect(@co1 == @col2).to eq(false)
      end
      # it "should returns true" do
      # 	expect(@co1==@col3).to eq(true)
      # end
    end
  end
  describe '#relname' do
    it 'should have relname' do
      expect(@col.relname).to eq('r1')
    end
  end
  describe '#columnRef' do
    it 'should have columnRef' do
      expect(@col.columnRef).to eq(%w(r1 c1))
    end
  end
end
