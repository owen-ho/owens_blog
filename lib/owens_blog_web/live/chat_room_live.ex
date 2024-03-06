defmodule OwensBlogWeb.ChatRoomLive do
  @moduledoc """
  Chat room page where users can communicate with messages passed through websockets
  """
  use OwensBlogWeb, :live_view
  require Logger

  @impl true
  def mount(%{"room_id" => room_id}, %{"csp_nonce_value" => csp_nonce_value} = _session, socket) do
    topic = "room:" <> room_id

    username = MnemonicSlugs.generate_slug(2)

    if connected?(socket) do
      OwensBlogWeb.Endpoint.subscribe(topic)
      # Self = PID, key is username, metadata set to empty

      OwensBlogWeb.Presence.track(self(), topic, username, %{})
      OwensBlogWeb.Presence.track(self(), "chat_rooms", room_id, %{})
    end

    {:ok,
     assign(socket,
       chatFormInput: "",
       room_id: room_id,
       username: username,
       form: to_form(%{}),
       messages: [],
       user_list: [],
       csp_nonce_value: csp_nonce_value,
       page_title: " | #{room_id}"
     ), temporary_assigns: [messages: []]}
  end

  @impl true
  def handle_event("submit-message", params, socket) do
    %{"message" => message} = params

    message = %{
      type: :user,
      id: UUID.uuid4(),
      content: message,
      username: socket.assigns.username
    }

    OwensBlogWeb.Endpoint.broadcast(
      "room:" <> socket.assigns.room_id,
      "new-message",
      message
    )

    {:noreply, assign(socket, form: to_form(%{}), chatFormInput: "")}
  end

  @impl true
  def handle_event("form_update", %{"message" => message}, socket) do
    {:noreply, socket |> assign(chatFormInput: message, form: to_form(%{}))}
  end

  @impl true
  def handle_info(%{event: "new-message", payload: message}, socket) do
    {:noreply, socket |> assign(messages: [message])}
  end

  @impl true
  def handle_info(%{event: "presence_diff", payload: %{joins: joins, leaves: leaves}}, socket) do
    joined_messages =
      joins
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, id: UUID.uuid4(), content: "#{username} joined"}
      end)

    leave_messages =
      leaves
      |> Map.keys()
      |> Enum.map(fn username ->
        %{type: :system, id: UUID.uuid4(), content: "#{username} left"}
      end)

    user_list = OwensBlogWeb.Presence.list("room:" <> socket.assigns.room_id)

    {:noreply,
     socket
     |> assign(messages: joined_messages ++ leave_messages, user_list: user_list |> Map.keys())}
  end

  def display_message(assigns) do
    case assigns.message.type do
      :system ->
        ~H"""
        <p id={assigns.message.id}>
          <em>system</em> <%= assigns.message.content %>
        </p>
        """

      _ ->
        ~H"""
        <p id={assigns.message.id}>
          <strong><%= assigns.message.username %></strong>: <%= assigns.message.content %>
        </p>
        """
    end
  end
end
