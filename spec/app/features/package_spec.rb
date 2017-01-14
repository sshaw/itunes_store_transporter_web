require "spec_helper"
require "itunes/store/transporter/web/search"

feature "Browsing packages", :js do
  STATUSES = ITunes::Store::Transporter::Web::Search::Package::Where::KNOWN_STATUSES

  STATUSES.each do |status|
    scenario "Filtering by current status '#{status}'" do
      hide = create(:package, :current_status => "Foo")
      show = create(:package, :current_status => status)

      visit app.url(:packages)
      find_field("current_status").select(status)

      expect(page).to have_text(show.vendor_id)
      expect(page).to_not have_text(hide.vendor_id)
    end
  end

  scenario "Filtering by current status '!= On Store'" do
    hide = create(:package, :current_status => "On Store")
    show = create(:package, :current_status => "Foo")

    visit app.url(:packages)
    find_field("current_status").select("!= On Store")

    expect(page).to have_text(show.vendor_id)
    expect(page).to_not have_text(hide.vendor_id)
  end

  scenario "Filtering by current status 'Other'" do
    hidden = STATUSES.map { |status| create(:package, :current_status => status) }
    show = create(:package, :current_status => "Foo")

    visit app.url(:packages)
    find_field("current_status").select("Other")

    expect(page).to have_text(show.vendor_id)
    hidden.each do |pkg|
      expect(page).to_not have_text(pkg.vendor_id)
    end
  end

  scenario "Editing a package" do
    pkg = create(:package)

    visit app.url(:packages)
    click_on "Edit"

    fill_in "Vendor ID", :with => "FooFooFoo"
    click_on "Update"

    expect(page).to have_text("Package updated")
    expect(page).to have_text("FooFooFoo")
    expect(page).to_not have_text(pkg.vendor_id)
  end

  scenario "Deleting a package" do
    pkg = create(:package)

    visit app.url(:packages)

    accept_alert { click_on "Delete" }
    expect(page).to_not have_text(pkg.vendor_id)

    expect(Package.where(:id => pkg.id)).to_not exist
  end
end
