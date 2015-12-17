require "spec_helper"

feature "Lookup metadata", :js do
  before do
    @account = create(:account)
  end

  ["Vendor ID", "Apple ID"].each do |id|
    it "creates a job for the given #{id}" do
      visit app.url(:lookup)

      select id, :from => "lookup_form[package_id]"
      fill_in "lookup_form[package_id_value]", :with => "X123"
      select "Low", :from => "Priority"
      select @account.username, :from => "Account"

      click_button "Lookup"

      expect(page).to have_text(/Lookup job added/)
    end
  end
end
