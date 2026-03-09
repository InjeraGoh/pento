defmodule PentoWeb.WrongLive do
  use PentoWeb, :live_view

  # =========================================================
  # Types (grouped) — for readability + learning
  # =========================================================

  @typedoc "The LiveView socket type"
  @type socket_t :: Phoenix.LiveView.Socket.t()                       # (or remove socket_t entirely if you want)

  @typedoc "Event names that this LiveView handles"
  @type event_name :: String.t()

  @typedoc """
    Params payload for the 'guess' event.
    phx-value-number sends a string value, e.g. %{"number" => "7"}
  """
  @type guess_params :: map()

  @typedoc "Generic params payload (used by events like 'restart' where we don't care)."
  @type event_params :: map()

  # @typedoc "Return type for mount/3"
  # @type mount_result :: {:ok, socket_t()}

  @typedoc "Return type for handle_event/3"
  @type noreply_result :: {:noreply, socket_t()}

  # =========================================================
  # LiveView lifecycle
  # =========================================================

  @doc """
  Initializes the LiveView when `/guess` is visited. This sets up the initial game state (score, message, answer, won, time).
  """

  @impl true
@spec mount(map(), map(), Phoenix.LiveView.Socket.t()) :: {:ok, Phoenix.LiveView.Socket.t()}
  def mount(_params, _session, socket) do
    # {:ok, new_game(socket)}

    # user = socket.assigns.current_scope.user

    user = socket.assigns.current_scope.user
    {
      :ok,
      assign(
        socket,
        score: 0,
        message: "Guess a number.",
        current_user: user
      )
    }

  {:ok,
   socket
   |> new_game()
   |> assign(:current_user, user)}
  end

  # =========================================================
  # Events
  # =========================================================

  @doc """
  Handles a number click from the UI.

  Receives params like: %{"number" => "10"}
    - converts guess to integer
    - compares against the secret answer
    - updates assigns (score/message/time, and won if correct)
  """
  @impl true
@spec handle_event(event_name(), guess_params() | event_params(), socket_t()) :: noreply_result()
  def handle_event("guess", %{"number" => guess}, socket) do
    guess = String.to_integer(guess)
    answer = socket.assigns.answer

    cond do
      socket.assigns.won ->
        # If already won, ignore extra clicks
        {:noreply, socket}

      guess == answer ->
        {:noreply,
         assign(socket,
           won: true,
           score: socket.assigns.score + 1,
           message: "✅ Correct! The answer was #{answer}. You win!",
           time: time()
         )}

      true ->
        {:noreply,
         assign(socket,
           score: socket.assigns.score - 1,
           message: "You guessed #{guess}. ❌ Wrong. Guess again.",
           time: time()
         )}
    end
  end

    #  Handles the restart button click. Resets the game state.

  @impl true
@spec handle_event(event_name(), guess_params(), socket_t()) :: noreply_result()
  def handle_event("restart", _params, socket) do
    {:noreply, new_game(socket)}
  end

  # =========================================================
  # Rendering
  # =========================================================

  @doc """
  Renders the game UI.

  - Shows buttons 1..10 while playing
  - Shows Restart button after winning
  """
  @impl true
  @spec render(map()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <main class="px-4 py-20 sm:px-6 lg:px-8">
      <h1 class="mb-4 text-4xl font-extrabold">Your score: {@score}</h1>

      <h2 class="mb-2">
        {@message}
      </h2>

      <p class="mb-6">
        It's {@time}
      </p>

      <%= if @won do %>
        <.button phx-click="restart">Restart</.button>
      <% else %>
        <div class="flex flex-wrap gap-2">
          <%= for n <- 1..10 do %>
            <.link
              class="btn btn-secondary"
              phx-click="guess"
              phx-value-number={n}
            >
              {n}
            </.link>
          <% end %>
        </div>
      <% end %>
      <h2>
        Current User: { @current_user.username } ({ @current_user.email })
      </h2>
    </main>
    """
  end

  # =========================================================
  # Helpers
  # =========================================================

  @doc false
  @spec new_game(Phoenix.LiveView.Socket.t()) :: Phoenix.LiveView.Socket.t()
  defp new_game(socket) do
    assign(socket,
      score: 0,
      message: "Make a guess:",
      answer: Enum.random(1..10),
      won: false,
      time: time()
    )
  end

  @doc false
  @spec time() :: String.t()
  def time do
    DateTime.utc_now() |> to_string()
  end
end



# =========================================================

# Get To Know LiveView - Guessing Game, Attempt 1

# defmodule PentoWeb.WrongLive do
#   use PentoWeb, :live_view

#   # =========================================================
#   # (Helper) Time function from the earlier "Send Network Diffs" section
#   # - Used so you can SEE that assigns changing causes re-render diffs.
#   # =========================================================
#   def time do
#     DateTime.utc_now() |> to_string()
#   end


# @doc """
#   REQUIREMENT 1:
#     "Assign a random number to the socket when the game is created,
#     one the user will need to guess."

#     We do this in a helper so we can also reuse it for restarting.
# """

#   defp new_game(socket) do
#     assign(socket,
#       # existing game state
#       score: 0,
#       message: "Make a guess:",

#       # NEW: secret answer stored in socket assigns
#       answer: Enum.random(1..10),

#       # NEW: whether the user has won
#       won: false,

#       # optional: store time in assigns so it updates on events
#       time: time()
#     )
#   end

# @doc """
#   LiveView Lifecycle:
#     mount/3 runs when /guess is first loaded.
#     Here we initialize all socket assigns via new_game/1.
# """

# @spec mount(any(), any(), any()) :: {:ok, any()}
#   @impl
#     def mount(_params, _session, socket) do
#     {:ok, new_game(socket)}
#   end


# @doc """
#   REQUIREMENT 2:
#     "Check for that number in the handle_event for guess."

#     The click sends: phx-click="guess", phx-value-number={n}
#     So params looks like: %{"number" => "7"}
# """

#   @impl true
#   def handle_event("guess", %{"number" => guess}, socket) do
#     # Convert the incoming guess from string -> integer
#     guess = String.to_integer(guess)

#     # Read the secret answer from socket assigns
#     answer = socket.assigns.answer

#     # =========================================================
#     # REQUIREMENT 3:
#     # "Show a winning message when the user guesses the right number
#     #  and increment their score in the socket assigns."
#     #
#     # REQUIREMENT 2 is also here: compare guess vs answer.
#     # =========================================================

#     cond do
#       socket.assigns.won ->
#         # If already won, ignore further guesses
#         {:noreply, socket}

#       guess == answer ->
#         {:noreply,
#          assign(socket,
#            won: true,
#            score: socket.assigns.score + 1,
#            message: "✅ Correct! The answer was #{answer}. You win!",
#            time: time()
#          )}

#       true ->
#         # Wrong guess branch: update message, decrement score (your choice)
#         {:noreply,
#          assign(socket,
#            score: socket.assigns.score - 1,
#            message: "You guessed #{guess}. ❌ Wrong. Guess again.",
#            time: time()
#          )}
#     end
#   end

# @doc """
#   REQUIREMENT 4:
#     "Show a restart message and button when the user wins."

#     The button triggers this event: phx-click="restart"
#     This resets the state by calling new_game/1 again.

#     NOTE about the book hint:
#     It suggests you might use LiveView navigation with "patch" as a stretch goal.
#     This implementation is the simpler version (no patch yet).
# """

#   @impl true
#   def handle_event("restart", _params, socket) do
#     {:noreply, new_game(socket)}
#   end

#   # =========================================================
#   # Render:
#   # - Displays score, message, time
#   # - If won: show Restart button
#   # - Else: show 1..10 guess buttons
#   #
#   # This directly maps to requirement 4 (restart UI on win).
#   # =========================================================
#   @impl true
#   def render(assigns) do
#     ~H"""
#     <main class="px-4 py-20 sm:px-6 lg:px-8">
#       <h1 class="mb-4 text-4xl font-extrabold">Your score: {@score}</h1>

#       <h2 class="mb-2">{@message}</h2>
#       <p class="mb-6">It's {@time}</p>

#       <%= if @won do %>
#         <.button phx-click="restart">Restart</.button>
#       <% else %>
#         <div class="flex flex-wrap gap-2">
#           <%= for n <- 1..10 do %>
#             <.link
#               class="btn btn-secondary"
#               phx-click="guess"
#               phx-value-number={n}
#             >
#               {n}
#             </.link>
#           <% end %>
#         </div>
#       <% end %>
#     </main>
#     """
#   end
# end

  # =========================================================

# TUTORIALS FROM THE BOOK

# defmodule PentoWeb.WrongLive do
#   use PentoWeb, :live_view

# def mount(_params, _session, socket) do
#   {:ok,
#    assign(socket,
#      score: 0,
#      message: "Make a guess:",
#      time: time()
#    )
#   }
# end


#   def render(assigns) do
#   ~H"""
#   <main class="px-4 py-20 sm:px-6 lg:px-8">
#     <h1 class="mb-4 text-4xl font-extrabold">Your score: {@score}</h1>

# <h2>
#   {@message}
#   It's {@time}
# </h2>

#     <br />

#     <h2>
#       <%= for n <- 1..10 do %>
#         <.link
#           class="btn btn-secondary"
#           phx-click="guess"
#           phx-value-number={n}
#         >
#           {n}
#         </.link>
#       <% end %>
#     </h2>
#   </main>
#   """
# end

# def handle_event("guess", %{"number" => guess}, socket) do
#   message = "Your guess: #{guess}. Wrong. Guess again. "
#   score = socket.assigns.score - 1
#   {
#       :noreply,
#       assign(
#         socket,
#         message: message,
#         score: score
#       )
#   }
# end

# def time() do
#   DateTime.utc_now() |> to_string()                     # Missing "socket.assigns.time" update
# end

# def handle_event("guess", %{"number" => guess}, socket) do
#   message = "You guess: #{guess}. Wrong. Guess again."
#   score = socket.assigns.score - 1

#   {:noreply,
#    assign(socket,
#      message: message,
#      score: score,
#      time: time()
#    )}
# end

# end
