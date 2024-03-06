defmodule OwensBlogWeb.LightLive do
  @moduledoc """
  Light page used to test out the live part of liveview
  """
  use OwensBlogWeb, :live_view

  # Creates initial state for socket
  def mount(_params, %{"csp_nonce_value" => csp_nonce_value} = _session, socket) do
    {:ok,
     assign(socket, brightness: 10, csp_nonce_value: csp_nonce_value, page_title: " | Lightroom")}
  end

  def handle_event("on", _, socket) do
    socket = assign(socket, :brightness, 100)
    {:noreply, socket}
  end

  def handle_event("off", _, socket) do
    socket = assign(socket, :brightness, 0)
    {:noreply, socket}
  end

  def handle_event("down", _, socket) do
    socket = update(socket, :brightness, &max(&1 - 10, 0))
    {:noreply, socket}
  end

  def handle_event("up", _, socket) do
    socket = update(socket, :brightness, &min(&1 + 10, 100))
    {:noreply, socket}
  end

  @spec render(any()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div class="text-white dark">
      <h1>Front Porch Light</h1>
      
      <div id="light">
        <div class={if @brightness == 0, do: "meter0", else: "meter"}>
          <span class={"w-[#{@brightness}%]"}>
            <%= if @brightness != 0 do %>
              <%= @brightness %>%
            <% end %>
          </span>
          
          <div class={if @brightness == 0, do: "number", else: "hidden"}>
            <%= @brightness %>%
          </div>
        </div>
        
        <button phx-click="off">
          Off
        </button>
        
        <button phx-click="on">
          On
        </button>
        
        <button phx-click="down">
          Down
        </button>
        
        <button phx-click="up">
          Up
        </button>
      </div>
    </div>
    """
  end
end
