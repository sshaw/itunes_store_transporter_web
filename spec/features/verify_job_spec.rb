require "spec_helper"
require "fileutils"

feature "Verify a package's contents", :js do
  before do
    @account = create(:account)
    @package = create_package

    visit app.url(:verify)

    select_package @package
    select_account @account
  end

  after { FileUtils.rm_rf(@package) }

  scenario "Verifying the metadata" do
    click_button "Verify"

    expect(page).to have_text("Queued")

    expect_to_have_package(@package)
    expect_to_have_account(@account)

    expect(page).to have_text("Verify job added")
    expect(page).to have_text(/Batch\s+false/)
    expect(page).to have_text(/Verify Assets\s+false/)
  end

  scenario "Verifying the metadata and assets" do
    check "Verify assets"
    click_button "Verify"

    expect(page).to have_text("Verify job added")
    expect(page).to have_text(/Verify Assets\s+true/)
  end

  scenario "Verifying a batch of packages" do
    check "Batch verify"
    click_button "Verify"

    expect(page).to have_text("Verify job added")
    expect(page).to have_text(/Batch\s+true/)
  end
end
