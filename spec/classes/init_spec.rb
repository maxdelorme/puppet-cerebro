require 'spec_helper'
describe 'cerebro' do
  context 'with default values for all parameters' do
    it { should contain_class('cerebro') }
  end
end
