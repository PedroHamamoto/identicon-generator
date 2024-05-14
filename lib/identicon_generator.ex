defmodule IdenticonGenerator do

  def main(username) do
    username
    |> hash_username
    |> pick_color
    |> build_grid
    |> filter_odd_squares
    |> build_pixel_map
    |> draw_image
    |> save_image(username)
  end

  defp hash_username(username) do
    seed = :crypto.hash(:md5, username)
    |> :binary.bin_to_list

    %Image{seed: seed}
  end

  defp pick_color(%Image{seed: [r, g, b | _tail]} = image) do
    %Image{image | color: {r, g, b}}
  end

  defp build_grid(%Image{seed: hex} = image) do
    grid =
      hex
      |> Enum.chunk_every(3, 3, :discard)
      |> Enum.map(&mirror_row/1)
      |> List.flatten
      |> Enum.with_index

    %Image{image | grid: grid}
  end

  defp mirror_row(row) do
    [first, second | _tail] = row
    row ++ [second, first]
  end

  defp filter_odd_squares(%Image{grid: grid} = image) do
    grid = Enum.filter grid, fn({code, _index}) ->
      rem(code, 2) == 0
    end

    %Image{image | grid: grid}
  end

  defp build_pixel_map(%Image{grid: grid} = image) do
    pixelm_map = Enum.map grid, fn({_code, index}) ->
      horizontal = rem(index, 5) * 50
      vertical = div(index, 5) * 50

      top_left = {horizontal, vertical}
      bottom_right = {horizontal + 50, vertical + 50}

      {top_left, bottom_right}
    end

    %Image{image | pixel_map: pixelm_map}
  end

  defp draw_image(%Image{color: color, pixel_map: pixel_map}) do
    image = :egd.create(250, 250)
    fill = :egd.color(color)

    Enum.each pixel_map, fn({start, stop}) ->
      :egd.filledRectangle(image, start, stop, fill)
    end

    :egd.render(image)
  end

  defp save_image(image, username) do
    File.write("#{username}.png", image)
  end
end
