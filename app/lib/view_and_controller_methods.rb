# encoding: UTF-8
# frozen_string_literal: true

module ViewAndControllerMethods
  private
    def no_interest
      @no_interest ||= Interest.order(:id).where(contactable: false).limit(1).first.id
    end

    def interest_levels
      return @interest_levels if @interest_levels
      @interest_levels = {}
      Interest.all.each do |interest|
        @interest_levels[interest.id] = interest.level
      end
      @interest_levels
    end

    # def monday(date = Date.today)
    #   Date.commercial date.end_of_week.year, date.cweek
    # end
    #
    # def last_monday
    #   monday - 7
    # end

    def render_relative(relative_path, options={})
      render options.
        merge(
          partial:  caller[0].
                      split(".")[0].
                      split("/")[0...-1].
                      join("/").
                      gsub(/.*\/app\/views\//, "") \
                    + "/#{relative_path}"
        )
    end

    def add_domain(str)
      (str.to_s =~ /^http/) ? str.to_s : "#{request.host}/#{str.sub(/^\//, '')}"
    end

    def bootstrap_version
      '4.2.1'
    end

    def client_ip_address
      request.env["HTTP_X_FORWARDED_FOR"].try(:split, ',').try(:last).presence ||
      get_ip_address
    end

    def gschema
      %Q(
        <link rel="canonical" href="#{path_data[:full_url]}">
        <meta itemprop="name" content="#{title}">
        <meta name="description" itemprop="description" content="#{path_data[:description].to_s}">
        #{path_data[:image].present? ? %Q(<meta itemprop="image" content="#{add_domain(path_data[:image])}">) : ''}
      ).html_safe
    end

    def ie_str
      (browser.ie? && !browser.edge?) ? 'is-ie' : ''
    end

    def meta_data
      {
        title: title,
        gschema: gschema,
        ograph: ograph,
        twitter: twitter,
      }
    end

    def mime_types
      {
        css: 'text/css; charset=UTF-8',
        js: 'application/javascript; charset=UTF-8',
        json: 'application/json; charset=UTF-8',
        svg: 'image/svg+xml; charset=UTF-8',
      }
    end

    def oembed_discovery
      %Q(
        <link rel="alternate" type="application/json+oembed" href="#{request.host}/oembed.json?url=#{encode_uri_component(request.original_url)}" title="#{title}" />
        <link rel="alternate" type="text/xml+oembed" href="#{request.host}/oembed.xml?url=#{encode_uri_component(request.original_url)}" title="#{title}" />
      ).html_safe
    end

    def ograph
      img_url = nil
      if path_data.present?
        %Q(
          <meta property="fb:app_id" content="#{Rails.application.credentials.dig(:facebook, :app_id)}">
          <meta property="og:url" content="#{path_data[:full_url]}">
          <meta property="og:type" content="website">
          <meta property="og:title" content="#{title}">
          #{path_data[:image].present? ? %Q(
            <meta property="og:image" content="#{img_url = add_domain(path_data[:image])}">
            <meta property="og:image:#{(img_url =~ /^https/) ? 'secure_' : ''}url" content="#{img_url}">
            <meta property="og:image:alt" content="#{title}">
          ) : ''}
          <meta property="og:description" content="#{path_data[:description].to_s}">
          <meta property="og:site_name" content="Down Under Sports">
          <meta property="og:locale" content="en_US">
        ).html_safe
      else
        ''.html_safe
      end
    end

    def path_data
      @path_data ||= {}
    end

    def title
      path_data[:title]
    end

    def twitter
      if path_data.present?
        %Q(
          <meta name="twitter:card" content="summary">
          <meta name="twitter:url" content="#{path_data[:full_url]}">
          <meta name="twitter:title" content="#{title}">
          <meta name="twitter:description" content="#{path_data[:description].to_s}">
          #{path_data[:image].present? ? %Q(<meta name="twitter:image" content="#{add_domain(path_data[:image])}">) : ''}
        ).html_safe
      else
        ''.html_safe
      end
    end

    def authenticated_user
      Auditing::CurrentUser.user
    end

    def pretty_date(date)
      raw(date.strftime("%A, %B %e<sup>#{date.day.ordinalize.sub(/\d+/, '')}</sup>, %Y"))
    end

    def pretty_short_date(date)
      raw(date.strftime("%B %e<sup>#{date.day.ordinalize.sub(/\d+/, '')}</sup>"))
    end

    def pretty_date_text(date)
      date.strftime("%A, %B #{date.day.ordinalize}, %Y")
    end

    def pretty_short_date_text(date)
      date.strftime("%B #{date.day.ordinalize}")
    end

    def generate_schedule_link(dus_id = nil)
      'mailto:mail@downundersports.com' \
        '?subject=Schedule%20an%20Appointment' \
        '&body=I%20would%20like%20to%20request%20a%20scheduled%20appointment%0D%0A%0D%0A' \
        'My Name:%20%0D%0A' \
        "#{dus_id.presence ? "Athlete%20DUS%20ID:%20#{dus_id}%0D%0A" : 'Athlete Name:%20%0D%0A' }" \
        'Date:%20%0D%0A' \
        'Time%20(with%20timezone):%20' \
        '%0D%0A%0D%0AI%20am%20curious%20about:%20'
    end

    def encode_uri_component(string)
      URI.escape(string.to_s, Regexp.new("[^#{URI::PATTERN::UNRESERVED}]"))
    end

    def encode64(str)
      require "base64"
      Base64.strict_encode64 str
    end
end
