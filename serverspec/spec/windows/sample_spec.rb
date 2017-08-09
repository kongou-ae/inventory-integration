require 'spec_helper'

describe file('c:/windows') do
  it { should be_directory }
end