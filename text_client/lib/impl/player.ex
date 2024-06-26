defmodule TextClient.Impl.Player do
  @typep game :: Hangman.game()
  @typep tally :: Hangman.Type.tally()
  @typep state :: {game, tally}

  @spec start() :: :ok
  def start() do
    game = Hangman.new_game()
    tally = Hangman.tally(game)
    interact({game, tally})
  end

  # @type state :: :initializing | :won | :lost | :good_guess | :bad_guess | :already_used

  @spec interact(state) :: :ok

  # i dont care tally is as a whole but its game_state to be :won
  def interact({_game, _tally = %{game_state: :won}}) do
    IO.puts("You won!")
  end

  # now i do need the whole tally
  def interact({_game, tally = %{game_state: :lost}}) do
    IO.puts("You lost ... the word was #{tally.letters |> Enum.join()}")
  end

  def interact({game, tally}) do
    IO.puts(feedback_for(tally))
    IO.puts(current_word(tally))

    Hangman.make_move(game, get_guess())
    |> interact()
  end

  # :initializing | :good_guess | :bad_guess | :already_used

  def feedback_for(tally = %{game_state: :initializing}) do
    "Welcome to Hangman! I'm thinking of #{tally.letters |> length()} letter word."
  end

  def feedback_for(%{game_state: :good_guess}) do
    "Good guess!"
  end

  def feedback_for(%{game_state: :bad_guess}) do
    "Bad guess!"
  end

  def feedback_for(%{game_state: :already_used}) do
    "You already tried that letter!"
  end

  def current_word(tally) do
    [
      "Word so far: ",
      tally.letters |> Enum.join(" "),
      "   turns left: ",
      tally.turns_left |> Integer.to_string(),
      "   used so far: ",
      tally.used |> Enum.join(",")
    ]
  end

  def get_guess() do
    IO.gets("Next letter: ")
    |> String.trim()
    |> String.downcase()
  end
end
