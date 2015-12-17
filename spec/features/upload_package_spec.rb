require "spec_helper"
require "fileutils"

feature "Upload a package", :js do
  before do
    @account = create(:account)
    @package = create_package
  end

  after { FileUtils.rm_rf(@package) }

  it "creates a job for the selected package" do
    visit app.url(:upload)

    click_on "Select Package"
    select_file @package
    fill_in "Rate", :with => 1234
    select "Aspera", :from => "Transport"
    select @account.username, :from => "Account"

    click_button "Upload"

    expect(page).to have_text(/Upload job added/)
  end
end
