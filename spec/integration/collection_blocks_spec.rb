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
        <ul>
          <li>1</li><li>2</li><li>3</li>
        </ul>

        <li>dos</li>
        <ul>
          <li>1</li><li>2</li><li>3</li>
        </ul>

        <li>tres!</li>
        <ul>
          <li>1</li><li>2</li><li>3</li>
        </ul>

      </ul>

      foo


      </body>
      </html>
    HTML
  end
end
