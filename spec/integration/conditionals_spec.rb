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


        foo 5
        foo 6
        foo 7
        foo 8
        foo 9


        foo 10


        foo 11


        foo 12


        foo 13

        foo 14



      </body>
      </html>
    HTML
  end
end
