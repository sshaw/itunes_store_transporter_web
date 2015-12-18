# coding: utf-8
require "spec_helper"
require "fileutils"

feature "Upload a package to the iTunes Store", :js do
  before do
    @account = create(:account)
    @package = create_package

    visit app.url(:upload)

    click_on "Select Package"
    select_file @package
    fill_in "Rate", :with => 1234
    select "Aspera", :from => "Transport"
    select @account.username, :from => "Account"
  end

  after { FileUtils.rm_rf(@package) }

  scenario "Uploading a package" do
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(@package)
    expect(page).to have_text(@account.username)
    expect(page).to have_text(@account.shortname)
    expect(page).to have_text(/On Success\s+—/)
    expect(page).to have_text(/On Failure\s+—/)
    expect(page).to have_text("Aspera")
    expect(page).to have_text(/Rate\s+1,234/)
    expect(page).to have_text("Normal")
    expect(page).to have_text(/Batch\s+false/)
    expect(page).to have_text(/Password\s+\*+/)
    expect(page).to have_text(/Delete on Success\s+false/)
  end

  %w[success failure].each do |action|
    scenario "Uploading a package with an 'on #{action}' directory" do
      click_on "open_file_browser_for_#{action}"
      select_file Dir.tmpdir
      click_button "Upload"

      expect(page).to have_text("Upload job added")
      expect(page).to have_text(/On #{action}\s+#{Dir.tmpdir}/i)
    end
  end

  scenario "Uploading a package that will be deleted on success" do
    check "Delete on success"
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Delete on Success\s+true/i)
  end

  scenario "Uploading a batch of packages" do
    check "Batch upload?"
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Batch\s+true/i)
  end
end
