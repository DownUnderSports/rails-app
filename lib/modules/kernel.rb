module Kernel
  private
    def local_port
      ENV['LOCAL_PORT'] || '3000'
    end

    def local_domain
      Rails.env.development? ? "lvh.me:#{local_port}" : "downundersports.com"
    end

    def local_protocol
      Rails.env.development? ? "http" : "https"
    end

    def local_host
      "#{local_protocol}://www.#{local_domain}"
    end

    def debugging_trace
      if Rails.env.development?
        trace = TracePoint.new(:call) { |tp| p [tp.path, tp.lineno, tp.event, tp.method_id] }
        trace.enable
        yield
        trace.disable
      else
        yield
      end
    end
end
