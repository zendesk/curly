describe "Using Curly for the application layout", type: :request do
  example "A simple layout view" do
    get '/'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <header>
        <h1>Dummy app</h1>
      </header>
      <h1>Dashboard</h1>
      <p>Hello, World!</p>
      <p>Welcome!</p>

      </body>
      </html>
    HTML
  end
end
