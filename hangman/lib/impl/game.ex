defmodule Hangman.Impl.Game do
  defstruct turns_left: 7,
            game_state: :initializing,
            letters: [],
            used: MapSet.new()

  def new_game do
    %Hangman.Impl.Game{
      letters: Dictionary.random_word() |> String.codepoints()
    }
  end
end
