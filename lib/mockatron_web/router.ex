defmodule MockatronWeb.Router do
  use MockatronWeb, :router

  alias MockatronWeb.Guardian

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

  pipeline :mock do
    plug MockatronWeb.Init
    plug MockatronWeb.FindCache, cache: :agent
    plug MockatronWeb.LoadAgent, repo: Mockatron.Repo
    plug MockatronWeb.ParsePathParams
    plug MockatronWeb.FilterMatch
    plug MockatronWeb.FindCache, cache: :responder
    plug MockatronWeb.LoadResponder
  end

  pipeline :jwt_authenticated do
    plug Guardian.AuthPipeline
  end

  scope "/v1/mockatron/auth", MockatronWeb do
    pipe_through :api
    post "/sign_up", UserController, :create
    post "/sign_in", UserController, :sign_in
  end

  scope "/v1/mockatron/ui", MockatronWeb do
    pipe_through :browser # Use the default browser stack
    get "/", PageController, :index
  end

  scope "/v1/mockatron/api", MockatronWeb do
    pipe_through [:jwt_authenticated, :api]
    resources "/agents", AgentController, except: [:new, :edit] do
      resources "/responses", ResponseController, except: [:new, :edit]
      resources "/filters", FilterController, except: [:new, :edit] do
        resources "/request_conditions", RequestConditionController, except: [:new, :edit]
        resources "/response_conditions", ResponseConditionController, except: [:new, :edit]
      end
    end
  end

  scope "/", MockatronWeb do
    pipe_through [:jwt_authenticated, :mock]
    match :*, "/*path", MockController, :response
  end

end
