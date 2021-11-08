defmodule TipayWeb.PageController do
  use TipayWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
