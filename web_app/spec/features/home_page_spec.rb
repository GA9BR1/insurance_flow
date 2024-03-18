require 'spec_helper'

describe 'home page' do
  context 'when the user is not logged in' do
    it 'should see the login page' do
      visit '/'
      expect(current_path).to eq '/login'
      expect(page).to have_content 'Login'
    end
  end
end
