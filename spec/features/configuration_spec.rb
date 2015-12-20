require "spec_helper"

feature "Configuration", :js do
  before do
    # Avoid account setup page
    create(:account)
    visit app.url(:config)
  end

  scenario "Configuring the Transporter" do
    # Uses the default location
    expect(page).to have_text("iTMSTransporter")

    click_on "Select Path"
    select_file Dir.tmpdir
    fill_in "Rate", :with => "999"
    select "Aspera", :from => "Transport"
    click_on "Save"

    expect(page).to have_text("Configuration saved")
    expect(page).to have_text(/Location:\s+#{File.basename(Dir.tmpdir)}\b/)
    expect(page).to have_css("span[data-content='#{Dir.tmpdir}']")
    expect(page).to have_field("Rate", :with => "999")
    expect(page).to have_field("Transport", :with => "Aspera")
  end
end
