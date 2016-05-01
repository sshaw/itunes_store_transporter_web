require "spec_helper"

feature "Retrieve package metadata from the iTunes Store", :js do
  before do
    @account = create(:account)

    visit app.url(:lookup)
    select_account @account
  end

  ["Vendor ID", "Apple ID"].each do |id|
    scenario "Retrieving metadata by a package's #{id}" do
      select id, :from => "lookup_form[package_id]"
      fill_in "lookup_form[package_id_value]", :with => "X123"
      click_button "Lookup"

      expect_to_have_account(@account)
      expect(page).to have_text("Lookup job added")
      expect(page).to have_text("X123")
    end
  end
end
