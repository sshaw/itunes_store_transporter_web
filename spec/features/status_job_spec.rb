require "spec_helper"

feature "Retrieve the status of an uploaded package", :js do
  before do
    @account = create(:account)

    visit app.url(:status)

    select_account @account
    fill_in "Vendor ID", :with => "X123"
  end

  scenario "Retrieving the status" do
    click_button "Status"

    expect_to_have_account(@account)

    expect(page).to have_text("Status job added")
    expect(page).to have_text("X123")
  end
end
