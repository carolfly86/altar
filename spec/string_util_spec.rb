require 'string_util'
describe String do	
	describe "#is_uuid?" do
		r ="44018798-6137-4c2d-948d-fd8a8c226fca"
		w = "hello"
	    it "should return true if string is a uuid format" do
	        expect(r.is_uuid?).to be true
	    end
	      it "should return false if string is not uuid format" do
	        expect(w.is_uuid?).to be false
	    end
	end
	describe "#is_number?" do
		r ="33.44"
		w = "hello"
	    it "should return true if string is numeric" do
	        expect(r.is_number?).to be true
	    end

	    it "should return false if string is not numeric" do
	        expect(w.is_number?).to be false
	    end
	end
	describe "#is_bool?" do
		a = %w[1 0 true false]
		r = a[rand(a.length)]
		w = "hello"
	    it "should return true if string is bool" do
	        expect(r.is_bool?).to be true
	    end

	    it "should return false if string is not bool" do
	        expect(w.is_bool?).to be false
	    end
	end
end
