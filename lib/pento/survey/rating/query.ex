defmodule Pento.Survey.Rating.Query do
  import Ecto.Query

  alias Pento.Survey.Rating

  def preload_user(user) do
    from(r in Rating,
      where: r.user_id == ^user.id
    )
  end
end
