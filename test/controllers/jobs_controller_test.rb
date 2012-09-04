require File.expand_path(File.dirname(__FILE__) + '/../test_config.rb')
require "tempfile"

class JobsControllerTest < CapybaraTestCase
  context "viewing the job list" do
    setup do
      @lookup = LookupJob.create! :options => options.merge(:vendor_id => "123")
      @schema = SchemaJob.create! :options => options.merge(:type => "strict", :version => "film123")
      visit "/"
    end
    
    should "display all the jobs" do
      assert has_content?(@lookup.target)
      assert has_content?(@schema.target)
    end
    
    should "link to the job" do
      click_link(@lookup.target)
      assert "/jobs/#{@lookup.id}", current_path
    end    
  end

  context "viewing a lookup job" do
    setup do
      Capybara.current_driver = :webkit
      @job = LookupJob.create! :options => options.merge(:vendor_id => "ID123")
      visit "/jobs/#{@job.id}"
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
        visit "/jobs/#{@job.id}"
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
          assert_equal "/jobs/#{@job.id}/metadata.xml", current_path
          assert has_xpath?("//x[text()='123']")
        end
      end
    end
  end

  # context "GET to results" do
  #   setup do
  #     @job = ProvidersJob.new(:options => options)
  #     @job.save!
  #     get "/jobs/#{@job.id}/result"
  #   end

  #   should "return the job's result section" do
  #     # no asscess...
  #     assert_equal render_job_result(@job), last_response.body
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

      @url = "/jobs/#{job.id}/output"
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
