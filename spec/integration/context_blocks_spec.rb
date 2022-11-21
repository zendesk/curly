require 'matchers/have_structure'

describe "Context blocks", type: :request do
  example "A context block" do
    get '/new'

    case "#{ActionPack::VERSION::MAJOR}.#{ActionPack::VERSION::MINOR}"
    when '6.1', '7.0'
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
    when '4.2', '5.1', '5.2', '6.0'
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
    else
      raise "curly-templates does not support Rails #{ActionPack::VERSION::MAJOR}.#{ActionPack::VERSION::MINOR}"
    end
  end
end
