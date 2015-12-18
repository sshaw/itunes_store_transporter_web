require "spec_helper"

feature "Retrieve package metadata on the iTunes Store", :js do
  before do
    @account = create(:account)
  end

  ["Vendor ID", "Apple ID"].each do |id|
    scenario "Retrieving metadata by a package's #{id}" do
      visit app.url(:lookup)

      select id, :from => "lookup_form[package_id]"
      fill_in "lookup_form[package_id_value]", :with => "X123"
      select @account.username, :from => "Account"

      click_button "Lookup"

      expect(page).to have_text("Lookup job added")
      expect(page).to have_text("X123")
      expect(page).to have_text(@account.username)
      expect(page).to have_text(@account.shortname)
      expect(page).to have_text(/Password\s+\*+/)
    end
  end
end
