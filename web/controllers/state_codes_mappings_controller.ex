defmodule SsnService.StateCodesMappingsController do

  use SsnService.Web, :controller

  def index(conn, _params) do
    json(conn, Repo.all(SsnService.State))
  end
end
