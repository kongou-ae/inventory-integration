require 'spec_helper'

puts property

describe port(80) do
  it { should be_listening }
end
