require 'spec_helper'

describe "Context blocks", type: :request do
  example "A context block" do
    get '/new'

    response.body.should == <<-HTML.strip_heredoc
      <html>
      <head>
        <title>Dummy app</title>
      </head>
      <body>
      <form accept-charset="UTF-8" action="/new" method="post"><div style="display:none"><input name="utf8" type="hidden" value="&#x2713;" /></div>
        <div class="field">
          <b>Name</b> <input id="dashboard_name" name="dashboard[name]" type="text" value="test" />
        </div>
      </form>
      </body>
      </html>
    HTML
  end
end
