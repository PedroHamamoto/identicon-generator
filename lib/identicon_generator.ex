defmodule IdenticonGenerator do

  def main(username) do
    username
    |> hash_username
  end

  defp hash_username(username) do
    :crypto.hash(:md5, username)
    |> :binary.bin_to_list
  end

end
