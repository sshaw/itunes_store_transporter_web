module FeatureActions
  def select_account(account)
    select account.username, :from => "Account"
  end

  def select_package(package)
    click_on "Select Package"
    select_file package
  end

  def select_file(path)
    parts = path.split("/")
    # Leading element is the volume on Win but empty on *nix
    parts.shift if parts[0].empty?

    # Double click expands, single click selects.
    # We have to sleep after clicking so that double click detection works
    # and jQuery.slideDown completes its expansion
    parts[0..-2].each do |part|
      2.times { click_on part }
      sleep 0.5
    end

    click_on parts[-1]
    sleep 0.5
    click_on "Select"
  end
end
