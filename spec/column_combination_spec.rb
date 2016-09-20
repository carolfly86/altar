require 'columns_combination'
describe Columns_Combination do	
	before :each do
		@cols = []
	    @col1 = Column.new
		@col1.relname = 'r1'
		@col1.colname = 'c1'
		@cols << @col1
		@col2 = Column.new
		@col2.relname = 'r2'
		@col2.colname = 'c2'
		@cols << @col2
		@col3 = Column.new
		@col3.relname = 'r3'
		@col3.colname = 'c3'
		@cols << @col3

		@cc = Columns_Combination.new(@cols)
	end
	describe "#new" do
	    it "returns a Columns_Combination object" do
	        expect(@cc).to be_an_instance_of Columns_Combination
	    end
	end
	describe "#encode" do
		context "colset = [c2,c3]" do
			it "should returns 6" do
				col3 = Column.new
				col3.relname = 'r3'
				col3.colname = 'c3'
				col2 = Column.new
				col2.relname = 'r2'
				col2.colname = 'c2'
				col_arry = []
				col_arry << col2
				col_arry << col3
				expect @cc.encode(col_arry)==6
			end
		end
	end
	describe "#decode" do
		context "string = '011'" do
			it "should returns [c1,c2]" do
				col_string = '011'
				col_arry = @cc.decode(col_string)
				expect col_arry.include?(@c1)
				expect col_arry.include?(@c2)
			end
		end
	end
end