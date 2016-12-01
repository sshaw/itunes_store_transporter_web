module FeatureMatchers
  def expect_to_have_package(package)
    expect(page).to have_text(package)
    expect(page).to have_text(File.basename(package))
  end

  def expect_to_have_account(account)
    expect(page).to have_text(account.display_name)
    expect(page).to have_text(account.shortname)
  end
end
