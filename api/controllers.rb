require "json"

ITunes::Store::Transporter::Web::API.controllers do
  [:lookup, :providers, :schema, :status, :upload, :verify].each do |route|
    name = route.to_s.capitalize

    post route, :provides => :json do
      job = "#{name}Job".constantize
      form = "#{name}Form".constantize.new(json_params)

      if form.valid?
        job = job.create!(form.marshal_dump)
        halt 201, { "Location" => url(:jobs, :id => job.id) }, job.to_json
      else
        halt 422, form.errors.to_json
      end
    end
  end

  get "jobs/search" do
    jobs = TransporterJob.search(params).paginate(:page => page(params[:page]),
                                                  :per_page => per_page(params[:per_page]))
    {
      :page => {
        :number => jobs.current_page,
        :size => jobs.per_page,
        :count => jobs.total_pages
      },

      :jobs => jobs.map(&:as_json)
    }.to_json
  end

  get :jobs, :with => :id do
    TransporterJob.find(params[:id]).to_json
  end

  helpers do
    def json_params
      @json_params ||= JSON.parse(request.body.read)
    end
  end
end
