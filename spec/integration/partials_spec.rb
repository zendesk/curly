require 'spec_helper'

describe "Using Curly for Rails partials", type: :request do
  example "Rendering a partial" do
    get '/partials'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <ul>
        <li>One</li>
        <li>Two</li>

      </ul>

      </body>
      </html>
    HTML
  end
end
