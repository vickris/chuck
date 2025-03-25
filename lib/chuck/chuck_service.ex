defmodule Chuck.ChuckService do
  def get_joke() do
    url = "https://api.chucknorris.io/jokes/random"
    headers = [{"Accept", "application/json"}]

    with {:ok, response} <- HTTPoison.get(url, headers),
         {:ok, joke} <- Jason.decode(response.body),
         %{"value" => _value, "id" => _id} <- joke do
      {:ok, joke}
    else
      {:error, %HTTPoison.Error{} = error} ->
        IO.puts("HTTP Error: #{inspect(error)}")
        error

      error ->
        IO.puts("Other ERRROR")
        error
    end
  end
end
