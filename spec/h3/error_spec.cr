require "../spec_helper"

describe H3::Error do
  describe ".check!" do
    it "does nothing for code 0" do
      H3::Error.check!(0_u32, "ctx").should be_nil
    end

    H3::ErrorCode.each do |error_code|
      it "raises the subclass for #{error_code}" do
        code = error_code.value
        ex = expect_raises(H3::Error) { H3::Error.check!(code, "ctx") }
        ex.class.name.should eq("H3::#{error_code}Error")
        ex.code.should eq(code)
        ex.error_code.should eq(error_code)
        ex.message.not_nil!.should contain(H3.describe_h3_error(code))
        ex.message.not_nil!.should contain("(code #{code})")
        ex.message.not_nil!.should start_with("ctx: ")
      end
    end

    it "raises the base error with the raw code for unknown codes" do
      ex = expect_raises(H3::Error) { H3::Error.check!(999_u32, "ctx") }
      ex.class.should eq(H3::Error)
      ex.code.should eq(999_u32)
      ex.error_code.should be_nil
      ex.message.not_nil!.should contain("(code 999)")
    end
  end
end
