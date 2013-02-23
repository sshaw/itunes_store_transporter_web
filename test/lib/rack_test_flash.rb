module Rack::Test::Flash
  def flash
    @_flash ||= begin
      # last_request.session["flash"] doesn't have it
      session = last_request.cookies["rack.session"].to_s.split("--", 2).first
      session ? (Marshal.load(session.unpack("m").first)["flash"] rescue {}) : {}
    end
  end

  def assert_flash_is_set(*options)
    opt  = options.shift
    test = lambda do
      case opt
      when Symbol
        !flash[opt].to_s.empty?
      when Hash
        key, val = opt.first
        Regexp === val ?
        flash[key] =~ val :
          flash[key] == val
      when Regexp
        flash.values.any? { |v| v =~ opt }
      when String
        flash.values.any? { |v| v == opt }
      else
        false
      end
    end

    args = [ test[] ]
    args << options.shift if options.any?
    assert *args
  end
end
