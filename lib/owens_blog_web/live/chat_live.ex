defmodule OwensBlogWeb.ChatLive do
  @moduledoc """
  Start of chat page where users can either join or create chat rooms
  """
  use OwensBlogWeb, :live_view
  require Logger

  @impl true
  def mount(_params, %{"csp_nonce_value" => csp_nonce_value} = _session, socket) do
    {:ok,
     assign(socket,
       query: "",
       form: to_form(%{}),
       csp_nonce_value: csp_nonce_value,
       page_title: " | Chat"
     )}
  end

  @impl true
  def handle_event("form_update", %{"room_code" => room_code}, socket) do
    {:noreply, socket |> assign(query: room_code, form: to_form(%{}))}
  end

  # implementation, adds extra messaging and error handling
  @impl true
  def handle_event("random-room", _metadata, socket) do
    random_slug = "/chat/" <> MnemonicSlugs.generate_slug(4)
    {:noreply, socket |> push_navigate(to: random_slug)}
  end

  @impl true
  def handle_event("join-room", _metadata, socket) do
    room = "/chat/" <> get_chat_room_id(socket.assigns.query)

    socket =
      case room do
        "/chat/" -> socket |> put_flash(:error, "No rooms found")
        _ -> socket |> push_navigate(to: room)
      end

    {:noreply, socket}
  end

  def get_chat_room_id("") do
    rooms = OwensBlogWeb.Presence.list("chat_rooms") |> Map.keys()
    if rooms |> Enum.empty?(), do: "", else: rooms |> Enum.random()
  end

  def get_chat_room_id(query) do
    query
  end
end
