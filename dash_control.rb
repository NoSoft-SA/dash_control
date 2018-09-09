# frozen_string_literal: true

require 'bundler'
Bundler.require(:default, ENV.fetch('RACK_ENV', 'development'))

require 'yaml'

ENV['ROOT'] = File.dirname(__FILE__)

# Dashboard Control routes.
class DashControl < Roda
  use Rack::Session::Cookie,
      secret: 'this_nice_long_random_string_DSKJH4309234KJHFS7EGKUFH',
      key: '_dash_session'
  use Rack::MethodOverride # Use with all_verbs plugin to allow 'r.delete' etc.
  plugin :all_verbs
  plugin :render, template_opts: { default_encoding: 'UTF-8' }
  plugin :partials
  plugin :assets, css: 'style.scss', precompiled: 'prestyle.css'
  plugin :public # serve assets from public folder.
  plugin :view_options
  plugin :content_for, append: true
  plugin :symbolized_params
  plugin :flash
  plugin :csrf, raise: true, skip_if: ->(_) { ENV['RACK_ENV'] == 'test' }
  # unless ENV['RACK_ENV'] == 'development' && ENV['NO_ERR_HANDLE']
  #   plugin :error_handler do |e|
  #     show_error(e,
  #                request.has_header?('HTTP_X_CUSTOM_REQUEST_TYPE'),
  #                @cbr_json_response)
  #   end
  # end

  route do |r| # rubocop:disable Metrics/BlockLength
    # r.assets unless ENV['RACK_ENV'] == 'production' Turn this for config...
    r.public

    r.root do
      view(inline: <<~HTML)
        <h1 class="ma0">Dashboard Control</h1>
        <p>Set up the configuration first and then call up a dashboard with the relevant key</p>
        <p>e.g. <a href="#{request.base_url}/dashboard/ph2">#{request.base_url}/dashboard/ph2</a> - where <strong><em>ph2</em></strong> is the key.</p>
        <p>Go to <a href="#{request.base_url}/list">#{request.base_url}/list</a> to see a list of the configured dashboards.</p>
      HTML
    end

    r.on 'dashboard', String do |key|
      # Note ALL dash keys must be lowercase...
      @dashboard_name, url_set = dashboard_for(key.downcase)
      r.redirect "/nodash/#{key}" if @dashboard_name.nil?
      content = <<~HTML
        <script>
          const frameSRC = Array(
            #{url_set.map { |a| "'#{a[0]}', #{a[1]}" }.join(', ')}
            );
          let i = 0;
          const len = frameSRC.length;

          function ChangeSrc() {
            if (i >= len) { i = 0; } // start over
            document.getElementById('frame').src = frameSRC[i++];
            setTimeout('ChangeSrc()', (frameSRC[i++]*1000));
          }

          window.onload = ChangeSrc;
        </script>
      HTML
      view(inline: content, layout: 'layout_main')
    end

    r.on 'image', String do |key|
      view(inline: "<img src=\"/images/#{key}\">",
           layout: 'layout_img')
    end

    r.on 'text', String do |key|
      content = text_for(key) || "<h1>NO CONTENT FOR #{key}</H1>"
      view(inline: content,
           layout: 'layout_txt')
    end

    r.on 'nodash', String do |key|
      "<h1>There are no dashboards configured for \"#{key}\".</h1>"
    end

    r.on 'list' do # rubocop:disable Metrics/BlockLength
      config = load_config('dashboards.yml')
      k1 = config.keys.first || 'keyname'
      out = [<<~HTML]
        <h1 class="ma0">Configured Dashboards</h1>
        <p>
          Load a board with a URL like: <a href="#{request.base_url}/dashboard/#{k1}">#{request.base_url}/dashboard/#{k1}</a>
          - where <em>#{k1}</em> is a key from the list below.
        </p>
        <table style="border-collapse:collapse">
        <thead><tr><th>Key</th><th>Description</th><th>URL</th>
        <th>Duration (Secs)</th></tr></thead><tbody>
      HTML
      css = 'class="bb pa2"'
      config.keys.each do |key|
        pre = <<~HTML
          <tr class="dim"><td #{css.sub('"', '"navy b ')}>#{key}</td>
          <td #{css}>#{config[key]['description']}</td>
        HTML
        config[key]['boards'].each do |board|
          out << <<~HTML
            #{pre}<td #{css}>#{board['url']}</td>
            <td #{css} align="right">#{board['secs']}</td></tr>
          HTML
          pre = "<tr class='dim'><td colspan='2'>&nbsp;</td>"
        end
      end
      out << '</tbody></table>'
      view(inline: out.join("\n"))
    end
  end

  def dashboard_for(key)
    config = section_from_yml('dashboards.yml', key)
    return [nil, nil] if config.nil?

    name = config['description']
    url_set = config['boards'].map do |dash|
      [dash['url'], dash['secs']]
    end
    [name, url_set]
  end

  def text_for(key)
    config = section_from_yml('text_contents.yml', key)
    return nil if config.nil?

    out = config.map do |section|
      styles = text_style(section)
      "<p style='#{styles.join(';')}'>#{section['text']}</p>"
    end
    out.join("\n")
  end

  def text_style(section)
    styles = []
    size = section['size'] || 1
    styles << "color:#{section['colour']}" if section['colour']
    styles << "font-size:#{size}rem"
    styles
  end

  def section_from_yml(file, key)
    load_config(file)[key]
  end

  def load_config(file)
    fn = File.join(ENV['ROOT'], 'config', file)
    YAML.load_file(fn)
  end
end
