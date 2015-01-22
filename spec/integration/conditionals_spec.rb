describe "Using Curly for Rails partials", type: :request do
  example "Rendering conditional blocks" do
    get '/conditionals'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>

        foo 1


        foo 2


        foo 3


        foo 4


      </body>
      </html>
    HTML
  end
end
