require 'spec_helper'

puts property

describe file('c:/windows') do
  it { should be_directory }
end