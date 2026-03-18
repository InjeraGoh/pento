defmodule Pento.Survey.Demographic.Query do
  import Ecto.Query

  alias Pento.Survey.Demographic

  def base do
    from(d in Demographic)
  end

  def for_user(query, %{user: user}) do
    where(query, [d], d.user_id == ^user.id)
  end
end
