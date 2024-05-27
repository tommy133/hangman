defmodule Dictionary.Runtime.Server do
  alias Dictionary.Impl.WordList

  @type t :: pid()

  def start_link do
    Agent.start_link(&WordList.word_list/0)
  end

  def random_word(pid) do
    Agent.get(pid, &WordList.random_word/1)
  end
end
