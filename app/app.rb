require "itunes/store/transporter/web/version"

class ItunesStoreTransporterWeb < Padrino::Application

  use ActiveRecord::ConnectionAdapters::ConnectionManagement

  register Sinatra::ConfigFile
  register Padrino::Rendering
  register Padrino::Helpers
  register WillPaginate::Sinatra
  register BootstrapForms

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
    # Block gets called when rake tasks are run and there's no guarantee that
    # the DB has been created
    if AppConfig.table_exists?
      AppConfig.output_log_directory = Padrino.root("tmp")
    end
  end

  configure :production do
    config_file ITMSWEB_CONFIG
    if AppConfig.table_exists?
      AppConfig.output_log_directory = settings.output_log_directory
    end
  end

  before do
    # For search form
    @accounts = Account.order(:username).all
  end

  before :except => %r{\A/account} do
    if @accounts.none?
      flash[:error] = "You must setup an account before you can continue."
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
    render :config
  end

  post :config do
    # Queued and resubmitted jobs will still have the old transporter path
    if @config.update_attributes(params[:app_config])
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
    @jobs = TransporterJob.joins(:account).order(order_by).paginate(paging_options)
    render "jobs/index"
  end

  get :search, "/jobs/search", :provides => [:html, :js] do
    @jobs = TransporterJob.joins(:account).search(params).order(order_by).paginate(paging_options)
    render "jobs/search"
  end

  get "/jobs/:id/status", :provides => :json do
    @jobs = TransporterJob.select("state").find(params[:id])
    @jobs.to_json
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
    job = TransporterJob.completed.find(params[:id])
    # Any Updated AppConfig options should be added...
    job = job.class.new(:options => job.options.dup)
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

  get "/" do
    redirect :jobs
  end

  protected
  def paging_options
    options = {}
    options[:page] = params[:page].to_i
    options[:page] = 1 unless options[:page] > 0
    options[:per_page] = params[:per_page].to_i
    options[:per_page] = 20 unless options[:per_page] > 0
    options
  end

  def order_by
    columns = TransporterJob.columns_hash.keys << "account"
    column = columns.include?(params[:order]) ? params[:order].dup : "created_at"

    column = "accounts.username" if column == "account"
    column << " " << (params[:direction] != "asc" ? "desc" : params[:direction])

    column
  end
end
