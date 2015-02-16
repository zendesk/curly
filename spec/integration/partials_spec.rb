describe "Using Curly for Rails partials", type: :request do
  example "Rendering a partial" do
    get '/partials'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <header>
        <h1>Dummy app</h1>
      </header>
      <ul>
        <li>One (yo)</li>
        <li>Two (yo)</li>

      </ul>

      </body>
      </html>
    HTML
  end
end
