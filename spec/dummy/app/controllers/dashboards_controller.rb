class DashboardsController < ApplicationController
  def show
    @message = "Hello, World!"
  end

  def collection
    @items = ["uno", "dos", "tres!"]
  end
end
