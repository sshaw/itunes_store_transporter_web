require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
require "tempfile"

class JobsControllerTest < CapybaraTestCase
  should_have_a_search_dialog("/")

  context "viewing the list of jobs" do
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

    context "when a job's Delete link is clicked" do
      setup do
        within("#job_#{@lookup.id}") { click_on "Delete" }
      end

      should "remove the job from the page" do
        assert has_no_selector?("#job_#{@lookup.id}")
      end
    end

    context "when a job's Resubmit link is clicked" do
      setup do
        within("#job_#{@lookup.id}") { click_on "Resubmit" }
        sleep 1
      end

      should "redirect to the resubmitted job's page" do
        assert_equal app.url(:job, TransporterJob.last.id), current_path
      end

      should "display a resubmitted message" do
        assert has_content?("Job resubmitted")
      end
    end
  end

  context "viewing a job" do
    setup do
      Capybara.current_driver = :webkit
      @job = LookupJob.create! :options => options.merge(:vendor_id => "ID123")
      visit app.url(:job, @job.id)
    end

    tabs = %w[Overview Results Output]
    tabs.each do |show|
      hide = tabs.dup
      hide.delete(show)
      
      context "when the #{show} tab is clicked" do
        setup { click_on show }
        
        should "display the job #{show}" do
          assert find("##{show.downcase}").visible?
        end
        
        hide.each do |tab|
          should "hide the job #{tab}" do
            assert !find("##{tab.downcase}").visible?
          end
        end
      end
    end
    
    context "when the Delete is clicked" do
      setup { click_on "Delete" }

      should "redirect to the jobs page" do
        assert_equal app.url(:jobs), current_path
      end

      should "display a 'job deleted' message" do
        assert has_content?("Job deleted.")
      end
    end

    %w[View Download].each do |action|
      should "not allow one to #{action} the job's output" do
        assert has_no_selector?("a", :text => action)
      end
    end

    context "when complete" do
      setup do
        @tmp = Tempfile.new ""
        @tmp.write "data"
        @tmp.flush

        @job = LookupJob.new :options => options.merge(:vendor_id => "ID123")
        @job.result = "<x>123</x>"
        @job.save!

        stub(@job).log { @tmp.path }
        stub(TransporterJob).find { @job }

        visit app.url(:job, @job.id)
      end

      context "the job's results" do
        setup { click_on "Results" }

        should "be displayed" do
          assert has_content?(@job.result)
        end

        should "be downloadable" do
          find("#results").click_on("Download")
          assert has_content?(@job.result)
        end

        should "allow one to view it outside of the job page" do
          find("#results").click_on("View")
          assert_equal app.url(:job_metadata, @job.id, :format => "xml"), current_path
          assert has_xpath?("//x[text()='123']")
        end
      end

      context "the job's output" do
        setup { click_on "Output" }

        should "be displayed" do
          assert has_content?(@job.output)
        end

        should "be downloadable" do
          find("#output").click_on("Download")
          assert has_content?(@job.output)
        end

        should "allow one to view it outside of the job page" do
          find("#output").click_on("View")
          assert_equal app.url(:job_output, @job.id, :format => "log"), current_path
          assert has_content?(@job.output)
        end
      end
    end
  end

  # context "GET to results" do
  #   setup do
  #     @job = LookupJob.new(:options => options)
  #     @job.result = "<x>123</x>"
  #     @job.save!

  #     get "/jobs/#{@job.id}/results"
  #   end

  #   should "return the job's result section" do
  #     #"#{Padrino.root}/app/views/jobs/results/_lookup.html.haml"
  #     assert_equal render_partial("jobs/results/#{@job.type.downcase}", :locals => { :job => @job }), last_response.body
  #   end
  # end

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
end
