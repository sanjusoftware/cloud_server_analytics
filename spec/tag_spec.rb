require "spec_helper"

describe "Tag" do

  it "should be same as the other tag if the key and values are same" do
    Database.establish_connection
    tag1 = Tag.new(:key => "key", :value => "value")
    tag2 = Tag.new(:key => "key", :value => "value")
    tag1.is_same?(tag2).should be true
  end
end