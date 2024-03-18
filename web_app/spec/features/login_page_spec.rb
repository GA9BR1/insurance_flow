require 'spec_helper'

describe 'login page' do
  context 'when the user is not logged in' do
    it 'should see the login page with all your principal elements' do
      visit '/login'
      expect(current_path).to eq '/login'
      expect(page).to have_content 'InsuranceFlow'
      expect(page).to have_content 'Login'
      expect(page).to have_field 'Email'
      expect(page).to have_field 'Senha'
      expect(page).to have_button 'Entrar'
      expect(page).to have_css('img[src="/images/google_logo.svg"]')
      expect(page).to have_content('Cognito')
    end
  end
  context 'user tries to logs in' do
    it 'using a valid email and password(own app authentication method)' do
      visit '/login'
      fill_in 'Email', with: 'gustavoalberttodev@gmail.com'
      fill_in 'Senha', with: '123456'
      click_button 'Entrar'
      expect(current_path).to eq '/'
      expect(page).to have_content 'Apólices'
    end
  end
end
