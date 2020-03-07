defmodule SsnService.Router do
  use SsnService.Web, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api/v1", SsnService do
    pipe_through :api
    post "/ssn", SsnController, :create
  end
end
