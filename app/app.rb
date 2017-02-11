require "itunes/store/transporter/web/version"

module ITunes
  module Store
    module Transporter
      module Web
        class App < Padrino::Application
          use ConnectionPoolManagement

          register Sinatra::ConfigFile
          register Padrino::Rendering
          register Padrino::Helpers
          register Padrino::Mailer
          register WillPaginate::Sinatra
          register BootstrapForms

          include PageNumber

          enable :sessions
          set :default_builder, TransporterFormBuilder
          set :haml, :ugly => true

          ### Our config
          enable :allow_select_transporter_path
          set :output_log_directory, Padrino.root("var/lib/output")
          set :file_browser_root_directory, FsUtil::DEFAULT_ROOT_DIRECTORY
          ###

          error ActiveRecord::RecordNotFound do
            "Not Found"
          end

          configure :development do
            set :output_log_directory, Padrino.root("tmp")
          end

          configure :production do
            config_file ITMSWEB_CONFIG
          end

          configure :test do
            set :delivery_method, :test
          end

          before do
            I18n.config = I18n::Env::Config.new

            # TODO: try settings with a Proc
            # FIXME: was in configure block, but it doesn't work with AR 4 + ar:create as there's no DB
            if Padrino.env == :development || Padrino.env == :production
              AppConfig.output_log_directory = settings.output_log_directory
            end
          end

          before :except => :browse do
            # For search form
            @accounts = Account.all
          end

          before :except => %r{\A/(?:account|browse)} do
            if @accounts.none?
              flash[:error] = "You must configure an iTunes Connect account before you can continue."
              redirect :accounts
            end
          end

          before :except => %r{\A/(?:job|account)} do
            @config = AppConfig.first_or_initialize
          end

          [:lookup, :providers, :schema, :status, :upload, :verify].each do |route|
            name = route.to_s.capitalize

            get route do
              form = "#{name}Form".constantize
              @options = form.new(@config.attributes)
              render route
            end

            post route do
              job  = "#{name}Job".constantize
              form = "#{name}Form".constantize

              @options = form.new(params["#{route}_form"])
              if @options.valid?
                @job = job.create!(@options.marshal_dump)
                flash[:success] = "#{name} job added to the queue."
                redirect url(:job, :id => @job.id)
              else
                render route
              end
            end
          end

          get :config do
            @notifications = Notification.includes(:account).all
            render :config
          end

          post :config do
            # Queued and resubmitted jobs will still have the old transporter path
            if @config.update_attributes(params[:transporter_config])
              flash[:success] = "Configuration saved."
              redirect :config
            else
              render :config
            end
          end

          post :browse do
            @files = FsUtil.ls(params[:dir],
                               :type => params[:type],
                               :root => settings.file_browser_root_directory)
            render :browse, :layout => false
          end

          get :jobs, :provides => [:html, :js] do
            @jobs = TransporterJob.search(params).paginate(paging_options)
            render "jobs/index"
          end

          get :search, "/jobs/search", :provides => [:html, :js] do
            @jobs = TransporterJob.search(params).paginate(paging_options)
            render "jobs/search"
          end

          get "/jobs/:id/status", :provides => :json do
            @jobs = TransporterJob.select("state").find(params[:id])
            @jobs.to_json(:only => :state)
          end

          get "/jobs/:id/results" do
            @job = TransporterJob.find(params[:id])
            render_job_result(@job)
          end

          # %r|/(?:jobs)?| ..!
          get :job, "/jobs", :with => :id do
            @job = TransporterJob.find(params[:id])
            render "jobs/show"
          end

          delete :job_delete, :map => "/jobs/:id", :provides => [:html, :js] do
            @job = TransporterJob.find(params[:id])
            @job.destroy
            if content_type == :js
              render "jobs/delete"
            else
              flash[:success] = "Job deleted."
              redirect :jobs
            end
          end

          post :job_resubmit, :map => "/jobs/:id/resubmit" do
            job = TransporterJob.completed.find(params[:id]).dup
            job.save!
            flash[:success] = "Job resubmitted."
            redirect url(:job, :id => job.id)
          end

          get :job_schema, :map => "/jobs/:id/schema", :provides => [:html, :xml] do
            job = SchemaJob.find(params[:id])
            if content_type == :html
              attachment "#{job.target}.rng"
            end

            content_type(:xml)
            job.result
          end

          get :job_metadata, :map => "/jobs/:id/metadata", :provides => [:html, :xml] do
            job = LookupJob.find(params[:id])
            if content_type == :html
              attachment "metadata.xml"
            end

            content_type(:xml)
            job.result
          end

          get :job_output, :map => "/jobs/:id/output", :provides => [:html, :log] do
            job = TransporterJob.find(params[:id])
            data = job.output(params[:offset].to_i)
            if content_type == :html
              filename = "#{job.type}-Job"
              filename << "-#{job.target}" if job.target.present?
              filename << ".log"
              attachment filename
            end

            content_type(:text)
            data
          end

          get :accounts do
            @account = Account.new
            render "accounts/new"
          end

          post :accounts do
            @account = Account.new(params[:account])
            if @account.save
              flash[:success] = "Account created."
              redirect :config
            else
              render "accounts/new"
            end
          end

          get :account, "/accounts", :with => :id do
            @account = Account.find(params[:id])
            render "accounts/edit"
          end

          patch :account_update, "/accounts/:id" do
            @account = Account.find(params[:id])
            if @account.update_attributes(params[:account])
              flash[:success] = "Account updated."
              redirect :config
            else
              render "accounts/edit"
            end
          end

          delete :account_delete, :map => "/accounts/:id", :provides => :js do
            @account = Account.find(params[:id])
            @account.destroy
            render "accounts/delete"
          end

          get "notifications/new" do
            @notification = Notification.new
            render "notifications/new"
          end

          get "notifications/config" do
            render "notifications/config"
          end

          patch "notifications/config" do
            if @config.update_attributes(params[:transporter_config])
              flash[:success] = "SMTP settings updated."
              redirect_to url(:config)
            else
              render "notifications/config"
            end
          end

          get :notifications, :with => :id do
            @notification = Notification.find(params[:id])
            render "notifications/edit"
          end

          patch :notifications, :with => :id do
            @notification = Notification.find(params[:id])
            if @notification.update_attributes(params[:notification])
              flash[:success] = "Notification updated."
              redirect :config
            else
              render "notifications/edit"
            end
          end

          delete :notifications, :with => :id, :provides => :js do
            @notification = Notification.find(params[:id])
            @notification.destroy
            render "notifications/delete"
          end

          post :notifications do
            @notification = Notification.new(params[:notification])

            if @notification.valid?
              @notification.save
              flash[:success] = "Notification created."
              redirect :config
            else
              render "notifications/new"
            end
          end

          get "/" do
            redirect :jobs
          end

          protected

          def default_per_page
            20
          end

          def paging_options
            { :page => page(params[:page]),
              :per_page => per_page(params[:per_page]) }
          end
        end
      end
    end
  end
end
