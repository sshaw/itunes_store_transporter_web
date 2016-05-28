require "spec_helper"

feature "Configuration", :js do
  before do
    # Creating an account also avoids redirects to account setup page
    @account = create(:account)
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
    # popup with absolute path
    expect(page).to have_css("span[data-content='#{Dir.tmpdir}']")
    expect(page).to have_field("Rate", :with => "999")
    expect(page).to have_field("Transport", :with => "Aspera")
  end

  scenario "Creating an account" do
    click_on "Accounts"
    click_on "New Account"

    expect(page).to have_text("New Account")

    fill_in "Username", :with => "sshaw"
    fill_in "Password", :with => "what_it_iz!@#"
    fill_in "Shortname", :with => "galinha"

    click_on "Create"

    expect(page).to have_text("Account created")

    click_on "Account"

    expect(page).to have_text("sshaw")
    expect(page).to have_text("galinha")
    expect(page).to_not have_text("what_it_iz!@#")
  end

  scenario "Editing an account" do
    click_on "Accounts"
    within_account @account do
      click_on "Edit"
    end

    fill_in "Username", :with => @account.username << "X"
    fill_in "Password", :with => "foo"
    fill_in "Shortname", :with => @account.shortname << "X"
    click_on "Update"

    expect(page).to have_text("Account updated")

    click_on "Account"

    within_account @account do
      expect(page).to have_text(@account.username)
      expect(page).to have_text(@account.shortname)
      expect(page).to_not have_text(@account.password)
    end
  end

  scenario "Deleting an account" do
    click_on "Accounts"
    within_account @account do
      click_on "Delete"
    end

    expect(page).to_not have_css("#account_#{@account.id}")
  end

  def within_account(account)
    within "#account_#{account.id}" do
      yield
    end
  end
end
