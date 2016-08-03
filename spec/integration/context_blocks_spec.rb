require 'matchers/have_structure'

describe "Context blocks", type: :request do
  example "A context block" do
    get '/new'

    expect(response.body).to have_structure <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <header>
        <h1>Dummy app</h1>
      </header>
      <form accept-charset="UTF-8" action="/new" method="post"><input name="utf8" type="hidden" value="&#x2713;" />
        <div class="field">
          <b>Name</b> <input id="dashboard_name" name="dashboard[name]" type="text" value="test" />
        </div>
      </form>

      <p>Thank you!</p>
      </body>
      </html>
    HTML
  end
end
