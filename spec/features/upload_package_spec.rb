# coding: utf-8
require "spec_helper"
require "fileutils"

feature "Upload a package to the iTunes Store", :js do
  before do
    @tmpdir = Dir.mktmpdir
    @account = create(:account)
    @package = create_package

    visit app.url(:upload)

    select_package @package
    select_account @account
  end

  after { FileUtils.rm_rf([@package, @tmpdir]) }

  scenario "Uploading a package" do
    fill_in "Rate", :with => 123
    select "Aspera", :from => "Transport"
    click_button "Upload"

    expect_to_have_package(@package)
    expect_to_have_account(@account)

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/On Success\s+—/)
    expect(page).to have_text(/On Failure\s+—/)
    expect(page).to have_text("Aspera")
    expect(page).to have_text(/Rate\s+123/)
    expect(page).to have_text(/Priority\s+Normal/)
    expect(page).to have_text(/Batch\s+false/)
    expect(page).to have_text(/Delete on Success\s+false/)

    click_on "Output"
    expect(page).to have_text("No output")

    click_on "Results"
    expect(page).to have_text("No results")
  end

  scenario "Uploading a high priority package" do
    select "High", :from => "Priority"
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Priority\s+High/)
  end

  scenario "Uploading a package with an 'on success' directory" do
    click_on "open_file_browser_for_success"
    select_file @tmpdir
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/On Success\s+#@tmpdir/)
    expect(page).to have_text(/On Failure\s+—/)
  end

  scenario "Uploading a package with an 'on failure' directory" do
    click_on "open_file_browser_for_failure"
    select_file @tmpdir
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/On Failure\s+#@tmpdir/)
    expect(page).to have_text(/On Success\s+—/)
  end

  scenario "Uploading a package that will be deleted on success" do
    check "Delete on success"
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Delete on Success\s+true/)
  end

  scenario "Uploading a package with an on completion executable" do
    program = Tempfile.new('itms-execute', @tmpdir)
    # TODO: Win
    File.chmod(0777, program.path)

    click_on "open_file_browser_for_execute"
    select_file program.path
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Execute\s+#{program.path}/)
  end

  scenario "Uploading a batch" do
    check "Batch upload"
    click_button "Upload"

    expect(page).to have_text("Upload job added")
    expect(page).to have_text(/Batch\s+true/)
    expect_to_have_package(@package)
  end

  # scenario "Selecting a batch directory that does not contain any .itmsp packages" do
  #   check "Batch upload"
  #   click_button "Upload"

  #   expect(page).to have_text("Upload job added")
  #   expect(page).to have_text(/Batch\s+true/)
  #   expect_to_have_package(@package)
  # end
end
