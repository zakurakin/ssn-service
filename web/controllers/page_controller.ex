defmodule SsnService.PageController do
  use SsnService.Web, :controller

  def index(conn, _params) do
    render conn, "index.html"
  end
end
