defmodule HangImplGameTestImpl do
  use ExUnit.Case
  alias Hangman.Impl.Game

  test "new game returns structure" do
    game = Game.new_game()
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert length(game.letters) > 0
  end

  test "new game returns correct word" do
    game = Game.new_game("wombat")
    assert game.turns_left == 7
    assert game.game_state == :initializing
    assert game.letters == ["w", "o", "m", "b", "a", "t"]
  end

  test "state doesn't change if a game is won or lost" do
    for state <- [:won, :lost] do
      game = Game.new_game("wombat")
      game = Map.put(game, :game_state, state)
      {new_game, _tally} = Game.make_move(game, "x")
      assert new_game == game
    end
  end

  test "a duplicate letter is reported" do
    game = Game.new_game()
    {new_game, _tally} = Game.make_move(game, "x")
    assert new_game.game_state !== :already_used
    {new_game, _tally} = Game.make_move(new_game, "y")
    assert new_game.game_state !== :already_used
    {new_game, _tally} = Game.make_move(new_game, "x")
    assert new_game.game_state == :already_used
  end

  test "we record letters used" do
    game = Game.new_game()
    {new_game, _tally} = Game.make_move(game, "x")
    {new_game, _tally} = Game.make_move(new_game, "y")

    assert MapSet.equal?(new_game.used, MapSet.new(["x", "y"]))
  end
end
