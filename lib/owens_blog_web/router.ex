defmodule OwensBlogWeb.Router do
  @moduledoc false
  alias OwensBlogWeb.BlogCreateLive
  use OwensBlogWeb, :router
  import Plug.BasicAuth

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {OwensBlogWeb.Layouts, :root}
    plug :protect_from_forgery

    # needed to know client's original IP as this is deployed behind nginx proxy
    plug RemoteIp

    # plug :put_secure_browser_headers, %{
    #   "content-security-policy" => "default-src 'self' 'nonce-asdasd'; img-src https:;"
    # }
    plug OwensBlog.Plugs.CustomSecureBrowserHeaders
  end

  pipeline :auth do
    plug :browser
    plug :basic_auth, username: "owen-admin-dashboard-woo", password: "NtXv#hWU24qkvq"
  end

  pipeline :post_auth do
    plug :browser
    plug :basic_auth, username: "owen-post-auth", password: "KE2&zz4LTaiou&6E8C!"
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", OwensBlogWeb do
    pipe_through :browser

    live "/", BlogLive, :index
    live "/blog/:post_id", BlogLive, :show
    live "/blog/tag/:tag", BlogLive, :index
    live "/light", LightLive
    live "/chat", ChatLive, :chat
    live "/chat/:room_id", ChatRoomLive, :chat_room
  end

  if Application.compile_env(:owens_blog, :debug) do
    scope "/create" do
      pipe_through :post_auth

      live "/blog_post", BlogCreateLive
    end
  end

  # Other scopes may use custom stacks.
  # scope "/api", OwensBlogWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:owens_blog, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :auth

      live_dashboard "/dashboard",
        metrics: OwensBlogWeb.Telemetry,
        csp_nonce_assign_key: :csp_nonce_value

      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end
end
