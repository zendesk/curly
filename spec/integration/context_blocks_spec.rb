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
      <form action="/new" accept-charset="UTF-8" method="post"><input name="utf8" type="hidden" value="&#x2713;" autocomplete="off" />
        <div class="field">
          <b>Name</b> <input value="test" type="text" name="dashboard[name]" id="dashboard_name" />
        </div>
      </form>

      <p>Thank you!</p>
      </body>
      </html>
    HTML
  end
end
