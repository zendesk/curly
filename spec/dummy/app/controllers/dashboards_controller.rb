class DashboardsController < ApplicationController
  def show
    @message = "Hello, World!"
  end

  def collection
    @name = "numbers"
    @items = ["uno", "dos", "tres!"]
  end

  def new
    @name = "test"
  end

  def conditionals
    @name = "test"
  end
end
