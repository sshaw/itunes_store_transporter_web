require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
require "tempfile"

class JobsControllerTest < CapybaraTestCase
  context "when the search link is clicked" do
    setup do
      Capybara.current_driver = :webkit
      visit "/"
      click_link "Search"
    end

    should "display the search form" do
      assert find("#search").visible?
    end

    context "when the clear link is clicked" do
      setup do
        select "Queued", :from => "state"
        select "Lookup", :from => "type"
        select "Normal", :from => "priority"
        fill_in "target", :with => "12345"
        fill_in "_updated_at_from", :with => "1/1/71"
        fill_in "_updated_at_to", :with => "1/1/72"
        click_link "Clear"
      end

      should "clear all the form fields" do
        within("#search") do
          all("select,input[type=text]").each { |e| assert e.value.empty?, "field '#{e[:name]}' not cleared" }
        end
      end
    end

    context "when the start date field receives the focus" do
      setup { find_field("_updated_at_from").trigger("focus") }

      should "display the calendar" do
        assert find(".ui-datepicker").visible?
      end
    end

    context "when the Search button is clicked" do
      setup do
        fill_in "target", :with => "12345"
        click_button "Search"
      end

      should "submit the form" do
        assert_equal "/jobs/search", current_path
      end
    end
  end

  context "viewing the job list" do
    setup do
      Capybara.current_driver = :webkit
      @lookup = LookupJob.create! :options => options.merge(:vendor_id => "vendor_id_123")
      @lookup.success!
      @schema = SchemaJob.create! :options => options.merge(:type => "strict", :version => "film123")
      visit "/"
    end

    should "display all the jobs" do
      assert has_content?(@lookup.target)
      assert has_content?(@schema.target)
    end

    context "when the Delete link is clicked" do
      setup do
        within("#job_#{@lookup.id}") { click_link("Delete") }
      end

      should "remove the job from the page" do
        assert has_no_content?(@lookup.target)
      end
    end

    should "link to the job" do
      click_link(@lookup.target)
      assert_equal app.url(:job, @lookup.id), current_path
    end

    context "when the Resubmit link is clicked" do
      setup do
        within("#job_#{@lookup.id}") { click_link("Resubmit") }
        #save_page
      end

      should "redirect to the resubmitted job's page" do
        assert_equal app.url(:job, TransporterJob.last.id), current_path
      end

      should "display a resubmitted message" do
        assert has_content?("Job resubmited")
      end
    end
  end

  context "viewing a lookup job" do
    setup do
      Capybara.current_driver = :webkit
      @job = LookupJob.create! :options => options.merge(:vendor_id => "ID123")
      visit app.url(:job, @job.id)
    end

    # --->
    should "display the job's state" do
      assert has_content?(@job.state.capitalize)
    end

    should "display the job's target" do
      assert has_content?(@job.target)
    end

    should "display the job's overview" do
      assert overview_visible?
    end

    should "not display the job's output" do
      assert !output_visible?
    end

    should "not display the job's resuts" do
      assert !output_visible?
    end
    # <---

    context "when the Delete link is clicked" do
      setup { click_link "Delete" }

      should "redirect to the jobs page" do
        assert_equal app.url(:jobs), current_path
      end

      should "display a 'job deleted' message" do
        assert has_content?("Job deleted.")
      end
    end

    context "when the Results link is clicked" do
      setup { click_link "Results" }

      should "display the results" do
        assert results_visible?
      end

      should "not display the overview" do
        assert !overview_visible?
      end

      should "not display the output" do
        assert !output_visible?
      end
    end

    context "when the Output link is clicked" do
      setup { click_link "Output" }

      should "display the output" do
        assert output_visible?
      end

      should "not display the results" do
        assert !results_visible?
      end

      should "not display the overview" do
        assert !overview_visible?
      end
    end
    # <---

    context "with results" do
      setup do
        @job = LookupJob.new :options => options.merge(:vendor_id => "ID123")
        @job.result = "<x>123</x>"
        @job.save!
        visit app.url(:job, @job.id)
        click_link "Results"
      end

      should "display the result" do
        assert has_content?(@job.result)
      end

      context "when the Download link is clicked" do
        should "download the result" do
          find("#results").click_link("Download")
          assert has_content?(@job.result)
        end
      end

      context "when the View link is clicked" do
        should "view the result" do
          find("#results").click_link("View")
          assert_equal app.url(:job_metadata, @job.id, :format => "xml"), current_path
          assert has_xpath?("//x[text()='123']")
        end
      end
    end
  end

  context "GET to results" do
    setup do
      @job = LookupJob.new(:options => options)
      @job.result = "<x>123</x>"
      @job.save!
      get "/jobs/#{@job.id}/results"
    end

    should "return the job's result section" do
      #"#{Padrino.root}/app/views/jobs/results/_lookup.html.haml"
      #assert_equal render_partial "jobs/results/#{job.type.downcase}", :locals => { :job => job }, last_response.body
      #assert_equal render_job_result(@job), last_response.body
    end
  end

  context "GET to status" do
    setup do
      @job = ProvidersJob.create!(:options => options)
      get "/jobs/#{@job.id}/status"
    end

    should "return the status of the job" do
      assert_equal @job.attributes.slice("state").to_json, last_response.body
    end
  end

  context "GET to output" do
    setup do
      @tmp = Tempfile.new ""
      @tmp.write "data"
      @tmp.flush

      job = ProvidersJob.create!(:options => options)
      stub(job).log { @tmp.path }
      stub(TransporterJob).find { job }

      @url = app.url(:job_output, job.id)
    end

    context "when the URL has no .log suffix" do
      setup { get @url }

      should "return the output as an attachement" do
        assert last_response.headers["Content-Disposition"] =~ /attachment;/
        assert_equal "data", last_response.body
      end
    end

    context "without an offset" do
      setup { get "#{@url}.log" }

      should "have a response type of text/plain" do
        assert_equal "text/plain;charset=utf-8", last_response.headers["Content-Type"]
      end

      should "return all the output" do
        assert_equal "data", last_response.body
      end
    end

    context "with an offset" do
      setup { get "#{@url}.log", :offset => 2 }

      should "have a response type of text/plain" do
        assert_equal "text/plain;charset=utf-8", last_response.headers["Content-Type"]
      end

      should "return the output starting at the offset" do
        assert_equal "ta", last_response.body
      end
    end
  end

  protected
  def overview_visible?
    find("#overview").visible?
  end

  def results_visible?
    find("#results").visible?
  end

  def output_visible?
    find("#output").visible?
  end
end
