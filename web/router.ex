defmodule SsnService.Router do
  use SsnService.Web, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", SsnService do
    pipe_through :browser # Use the default browser stack

    get "/", PageController, :index
  end

  scope "/api/v1", SsnService do
    pipe_through :api
    get "/state-codes", StateCodesMappingsController, :index
    post "/ssn", SsnController, :index
  end
end
