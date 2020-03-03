defmodule SsnService.StateCodesMappingsController do

  use SsnService.Web, :controller

  def index(conn, _params) do
    mappings = Repo.all(SsnService.State)
    IO.inspect mappings
    json conn, mappings
  end
end
