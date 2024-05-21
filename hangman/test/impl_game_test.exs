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

  test "we recognize a letter in the word" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "w")
    assert tally.game_state == :good_guess
    {_game, tally} = Game.make_move(game, "a")
    assert tally.game_state == :good_guess
  end

  test "we recognize a letter not in the word" do
    game = Game.new_game("wombat")
    {_game, tally} = Game.make_move(game, "x")
    assert tally.game_state == :bad_guess

    {_game, tally} = Game.make_move(game, "y")
    assert tally.game_state == :bad_guess

    {_game, tally} = Game.make_move(game, "t")
    assert tally.game_state == :good_guess
  end

  # hello
  test "can handle a sequence of move" do
    [
      # guess | state   turns letters                 used
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["a", :already_used, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 6, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["x", :bad_guess, 5, ["_", "e", "_", "_", "_"], ["a", "e", "x"]]
    ]
    |> test_sequence_of_moves()
  end

  test "handle a winning game" do
    [
      ["a", :good_guess, 7, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :good_guess, 7, ["_", "e", "_", "_", "_"], ["a", "e"]],
      ["l", :good_guess, 7, ["_", "e", "l", "l", "_"], ["a", "e", "l"]],
      ["o", :good_guess, 7, ["_", "e", "l", "l", "o"], ["a", "e", "l", "o"]],
      ["h", :good_guess, 7, ["h", "e", "l", "l", "o"], ["a", "e", "l", "o", "h"]],
      ["h", :already_used, 7, ["h", "e", "l", "l", "o"], ["a", "e", "l", "o", "h"]],
      ["w", :won, 7, ["h", "e", "l", "l", "o"], ["a", "e", "l", "o", "h", "w"]]
    ]
  end

  test "handle a losing game" do
    [
      ["a", :bad_guess, 6, ["_", "_", "_", "_", "_"], ["a"]],
      ["e", :bad_guess, 5, ["_", "_", "_", "_", "_"], ["a", "e"]],
      ["l", :bad_guess, 4, ["_", "_", "_", "_", "_"], ["a", "e", "l"]],
      ["o", :bad_guess, 3, ["_", "_", "_", "_", "_"], ["a", "e", "l", "o"]],
      ["h", :bad_guess, 2, ["_", "_", "_", "_", "_"], ["a", "e", "l", "o", "h"]],
      ["h", :already_used, 2, ["_", "_", "_", "_", "_"], ["a", "e", "l", "o", "h"]],
      ["w", :lost, 1, ["_", "_", "_", "_", "_"], ["a", "e", "l", "o", "h", "w"]]
    ]
  end

  def test_sequence_of_moves(script) do
    game = Game.new_game("hello")
    Enum.reduce(script, game, &check_one_move/2)
  end

  defp check_one_move([guess, state, turns, letters, used], game) do
    {new_game, tally} = Game.make_move(game, guess)
    assert tally.game_state == state
    assert tally.turns_left == turns
    assert tally.letters == letters
    assert tally.used == used
    new_game
  end
end
