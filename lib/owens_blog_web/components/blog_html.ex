defmodule OwensBlogWeb.BlogHTML do
  use OwensBlogWeb, :html

  def convert_time(time_stamp) do
    time_stamp
    |> Calendar.strftime("%d %b %Y")
  end

  def post_component(assigns) do
    ~H"""
    <article
      id={@post.id}
      class="flex flex-col gap-0 px-4 pt-3 pb-2 overflow-hidden shadow-xl bg-gray-200 dark:bg-gray-800 rounded-xl transition-transform ease-in-out duration-500"
    >
      <h2 class="font-semibold text-2xl">
        <.link href={~p"/blog/#{@post.id}"} class="hover:text-gray-300">
          <%= @post.title %>
        </.link>
      </h2>
      
      <span class="text-sm font-mono">
        <span><%= @post.author %></span>
        <span class="text-gray-500 dark:text-gray-400">| <%= convert_time(@post.date) %></span>
      </span>
      
      <div class="py-2 my-2 text-md leading-5 border-y-[1px] border-gray-400 dark:border-gray-700">
        <p class={
          if @expanded == true, do: "italic text-gray-500 dark:text-gray-400 text-sm", else: "italic"
        }>
          <%= raw(@post.description) %><%!-- raw() required to parse markdown properly --%>
        </p>
      </div>
      
      <%= if @expanded do %>
        <div class="mb-2 pb-3 text-md border-b-[1px] border-gray-400 dark:border-gray-700">
          <%= raw(@post.body) %>
        </div>
      <% end %>
      
      <p class="text-gray-700 dark:text-gray-400 text-xs italic font-serif">
        <%= for tag <- @post.tags do %>
          <a href={~p"/blog/tag/#{tag}"} class="hover:text-gray-500">
            <%= if @post.tags |> List.last() != tag do %>
              <%= tag %>,
            <% else %>
              <%= tag %>
            <% end %>
          </a>
        <% end %>
      </p>
    </article>
    """
  end
end
