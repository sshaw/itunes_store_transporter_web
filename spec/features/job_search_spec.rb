require "spec_helper"

feature "Job search", :js do
  it "finds job in the selected state" do
    found = create(:upload_job)
    found.running!

    not_found = create(:upload_job)
    not_found.success!

    visit app.url(:jobs)

    click_link "Search"
    select "Running", :from => "State"
    click_button "Search"

    expect(page).to have_text("Search: state Running")
    expect(page).to have_selector(".job", :text => "Running", :count => 1)
    expect(page).to have_no_selector(".job", :text => "Queued")
  end

  it "finds jobs of the selected type" do
    found = create(:upload_job)
    not_found = create(:lookup_job)

    visit app.url(:jobs)

    click_link "Search"
    select "Upload", :from => "Type"
    click_button "Search"

    expect(page).to have_text("Search: type Upload")
    expect(page).to have_selector(".job", :text => "Upload", :count => 1)
    expect(page).to have_no_selector(".job", :text => "Lookup")
  end

  it "finds jobs with the selected priority" do
    found = create(:upload_job, :priority => :high)
    not_found = create(:upload_job, :priority => :normal)

    visit app.url(:jobs)

    click_link "Search"
    select "High", :from => "Priority"
    click_button "Search"

    expect(page).to have_text("Search: priority High")
    expect(page).to have_selector(".job", :text => "High", :count => 1)
    expect(page).to have_no_selector(".job", :text => "Normal")
  end

  it "finds jobs with the given target" do
    found = create(:status_job)
    not_found = create(:status_job)

    visit app.url(:jobs)

    click_link "Search"
    fill_in "Target", :with => found.target
    click_button "Search"

    expect(page).to have_text(%{Search: target "#{found.target}"})
    expect(page).to have_selector(".job", :text => found.target, :count => 1)
    expect(page).to have_no_selector(".job", :text => not_found.target)
  end

  it "finds jobs for the given account" do
    found = create(:status_job).account
    not_found = create(:status_job).account

    visit app.url(:jobs)

    click_link "Search"
    select found.username, :from => "Account"
    click_button "Search"

    expect(page).to have_text(%{Search: account "#{found.username}"})
    expect(page).to have_selector(".job", :text => found.username, :count => 1)
    expect(page).to have_no_selector(".job", :text => not_found.username)
  end

  describe "searching by date" do
    before do
      @start_date = 10.days.ago
      @end_date = @start_date + 2.days

      @found = [ create(:status_job),  create(:status_job) ]
      @found[0].update_column(:updated_at, @start_date)
      @found[1].update_column(:updated_at, @end_date)

      @not_found = create(:lookup_job)

      visit app.url(:jobs)
    end

    context "selecting dates from the calendar"

    context "entering dates" do
      it "finds jobs updated on the given date", :pending => "Single date search broken, GitHub issue #5" do
        visit app.url(:jobs)

        click_link "Search"
        fill_in "_updated_at_from", :with => @start_date.strftime("%D")
        click_button "Search"

        expect(page).to have_text("Search: updated #{@start_date.strftime("%D")}")
        expect(page).to have_selector(".job", :text => @found[0].type, :count => 1)
        expect(page).to have_no_selector(".job", :text => @not_found.type)
      end

      it "finds jobs updated between the given date range" do
        click_link "Search"
        fill_in "_updated_at_from", :with => @start_date.strftime("%D")
        fill_in "_updated_at_to", :with => @end_date.strftime("%D")
        click_button "Search"

        expect(page).to have_text("Search: updated #{@start_date.strftime("%D")} to #{@end_date.strftime("%D")}")
        expect(page).to have_selector(".job", :text => @found[0].type, :count => 2)
        expect(page).to have_no_selector(".job", :text => @not_found.type)
      end
    end
  end
end
