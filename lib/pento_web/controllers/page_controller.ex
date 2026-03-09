defmodule PentoWeb.PageController do
  use PentoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end

#   def home(conn, _params) do
#     if conn.assigns[:current_scope] do
#       redirect(conn, to: ~p"/guess")
#     else
#       render(conn, :home)
#     end
#   end

 end
