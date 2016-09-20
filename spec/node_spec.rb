require 'node'
describe Node do	
	before :each do
	    @nd1 = Node.new
		@nd1.name='N1'
      	@nd1.query = 'salary > 120000'
      	@nd1.location = '58'
      	@nd1.columns = 'salary'
      	@nd1.suspicious_score = '8'

      	@nd2 = Node.new
		@nd2.name='N2'
      	@nd2.query = "from_date = '1990-02-23'"
      	@nd2.location = '81'
      	@nd2.columns = 'from_date'
      	@nd2.suspicious_score = '0'


      	@nd3 = Node.new
		@nd3.name='N3'
      	@nd3.query = "emp_no = 37558"
      	@nd3.location = '106'
      	@nd3.columns = 'emp_no'
      	@nd3.suspicious_score = '4'
	end
	describe "#new" do
	    it "returns a Node object" do
	        expect(@nd1).to be_an_instance_of Node
	    end
	end
	describe "#is_passed?" do
		context "emp_no: 66181 from_date: 1990-02-23 test against N1" do
			it "should returns false" do
				pkCond = "emp_no = 66181 and from_date = '1990-02-23'"
				type = 'M'
				test_id = 0
				expect @nd1.is_passed?(pkCond,test_id,type)==false
			end
		end
		context "emp_no: 66181 from_date: 1990-02-23 test against N2" do
			it "should returns true" do
				pkCond = "emp_no = 66181 and from_date = '1990-02-23'"
				type = 'M'
				test_id = 0
				expect @nd2.is_passed?(pkCond,test_id,type)==true
			end
		end
		# context "emp_no: 66181 from_date: 1990-02-23" do
		# 	it "should returns true" do
		# 		pkCond = "emp_no = 66181 and from_date = '1990-02-23'"
		# 		type = 'M'
		# 		test_id = 0
		# 		expect @nd.is_passed?(pkCond,test_id,type).to be false
		# 	end
		# end
		# context "emp_no: 66181 from_date: 1990-02-23" do
		# 	it "should returns true" do
		# 		pkCond = "emp_no = 66181 and from_date = '1990-02-23'"
		# 		type = 'M'
		# 		test_id = 0
		# 		expect @nd.is_passed?(pkCond,test_id,type).to be false
		# 	end
		# end
	end
	
end