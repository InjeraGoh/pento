defmodule PentoWeb.SurveyLive.Component do
  use Phoenix.Component

  attr :content, :string, required: true
  slot :inner_block, required: true
  def hero(assigns) do
    ~H"""
    <div class="hero bg-gradient-to-r from-blue-500 to-purple-600 text-white">
      <div class="hero-content text-center py-16">
        <div class="max-w-md">
          <h1 class="mb-5 text-5xl font-bold"><%= @content %></h1>
          <div class="mb-5 text-lg">
            <%= render_slot(@inner_block) %>
          </div>
        </div>
      </div>
    </div>
    """
  end

  attr :title, :string, required: true
  attr :message, :string, required: true
  def title_card(assigns) do
    ~H"""
    <div class="rounded-lg border border-base-300 bg-base-200 p-4">
      <h3 class="text-lg font-semibold"><%= @title %></h3>
      <p class="mt-2 text-sm"><%= @message %></p>
    </div>
    """
  end

  attr :text, :string, required: true
  def bullet_item(assigns) do
    ~H"""
    <li class="py-1"><%= @text %></li>
    """
  end

  attr :items, :list, required: true
  def bullet_list(assigns) do
    ~H"""
    <ul class="list-disc pl-6">
      <%= for item <- @items do %>
        <.bullet_item text={item} />
      <% end %>
    </ul>
    """
  end
end
