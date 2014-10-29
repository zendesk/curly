require 'spec_helper'

describe "Collection blocks", type: :request do
  example "Rendering collections" do
    get '/collection'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <ul>

        <li>uno</li>

        <li>dos</li>

        <li>tres!</li>

      </ul>

      </body>
      </html>
    HTML
  end
end
