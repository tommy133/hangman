defmodule Hangman do
  alias Hangman.Impl.Game
  alias Hangman.Type
  # opaque - keep ur fingers out of my internal state outside this module
  @opaque game :: Game.t()

  @spec new_game() :: game
  # def new_game do
  #   Game.new_game()
  # end
  defdelegate new_game, to: Game

  @spec make_move(game, String.t()) :: {game, Type.tally()}
  defdelegate make_move(game, guess), to: Game
end
