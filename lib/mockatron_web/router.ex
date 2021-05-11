defmodule MockatronWeb.Router do
  use MockatronWeb, :router

  alias MockatronWeb.Guardian

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, {MockatronWeb.LayoutView, :root}
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
    get "/verify", UserController, :verify_email
    get "/resend", UserController, :resend_token
  end

  scope "/v1/mockatron/ui", MockatronWeb do
    # Use the default browser stack
    pipe_through :browser
    live "/", PageLive, :index
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

  # Other scopes may use custom stacks.
  # scope "/api", MockatronWeb do
  #   pipe_through :api
  # end

  # Enables LiveDashboard only for development
  #
  # If you want to use the LiveDashboard in production, you should put
  # it behind authentication and allow only admins to access it.
  # If your application does not have an admins-only section yet,
  # you can use Plug.BasicAuth to set up some basic authentication
  # as long as you are also using SSL (which you should anyway).
  if Mix.env() in [:dev, :test] do
    import Phoenix.LiveDashboard.Router

    scope "/v1/mockatron/ui" do
      pipe_through :browser
      live_dashboard "/dashboard", metrics: MockatronWeb.Telemetry, ecto_repos: [Mockatron.Repo]
    end
  end

  scope "/", MockatronWeb do
    pipe_through [:jwt_authenticated, :mock]
    match :*, "/*path", MockController, :response
  end
end
