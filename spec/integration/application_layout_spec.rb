require 'spec_helper'

describe "Using Curly for the application layout", type: :request do
  example "A simple layout view" do
    get '/'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <h1>Dashboard</h1>
      <p>Hello, World!</p>

      </body>
      </html>
    HTML
  end
end
