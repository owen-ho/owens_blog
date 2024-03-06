defmodule OwensBlogWeb.BlogLive do
  @moduledoc """
  Blog live controller
  """
  require Logger
  use OwensBlogWeb, :live_view
  alias OwensBlog.Blog

  @impl true
  def mount(params, session, socket) do
    socket = assign_defaults(session, socket)
    %{"csp_nonce_value" => csp_nonce_value} = session

    socket =
      case params do
        %{"post_id" => post_id} ->
          socket |> assign(post: Blog.get_post_by_id!(post_id))

        %{"tag" => tag} ->
          socket |> assign(posts: Blog.get_posts_by_tag!(tag), tag: tag)

        _ ->
          socket |> assign(posts: Blog.all_posts())
      end

    {:ok,
     assign(
       socket,
       page_title: " | All Posts",
       search_form: to_form(%{}),
       search_query: "",
       csp_nonce_value: csp_nonce_value
     )}
  end

  # Extracts current url path from handle_params function and add it to assigns current_path variable
  defp assign_defaults(_session, socket) do
    {:cont, socket}

    socket =
      attach_hook(socket, :set_current_path, :handle_params, fn
        _params, url, socket ->
          {:cont, assign(socket, current_path: URI.parse(url).path)}
      end)

    socket
  end

  @impl true
  def handle_event("search_update", %{"query" => ""}, socket) do
    {:noreply, assign(socket, posts: Blog.all_posts())}
  end

  @impl true
  def handle_event("search_update", %{"query" => query}, socket) do
    posts = Blog.get_posts_by_search!(query)
    {:noreply, assign(socket, posts: posts)}
  end

  @impl true
  def handle_event("search_submit", _params, socket) do
    {:noreply, assign(socket, search_form: to_form(%{}), search_query: "")}
  end
end
