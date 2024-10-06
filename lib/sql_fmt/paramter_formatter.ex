defprotocol SqlFmt.PrintableParameter do
  # This code is taken from https://github.com/fuelen/ecto_dev_logger/blob/main/lib/ecto/dev_logger/printable_parameter.ex
  # with some minor changes being made to reduce external dependencies.
  @moduledoc false

  @doc """
  Converts term to a valid SQL expression.
  """
  @spec to_expression(any()) :: String.t()
  def to_expression(term)

  @doc """
  Converts term to a string literal.
  """
  @spec to_string_literal(any()) :: String.t() | nil
  def to_string_literal(term)
end

defmodule SqlFmt.Utils do
  @moduledoc false
  def in_string_quotes(string) do
    "'#{String.replace(string, "'", "''")}'"
  end

  def all_to_string_literal(list) do
    result =
      Enum.reduce_while(list, {:ok, []}, fn element, {:ok, acc} ->
        case SqlFmt.PrintableParameter.to_string_literal(element) do
          nil -> {:halt, :error}
          string_literal -> {:cont, {:ok, [{element, string_literal} | acc]}}
        end
      end)

    with {:ok, list} <- result do
      {:ok, Enum.reverse(list)}
    end
  end
end

defimpl SqlFmt.PrintableParameter, for: Atom do
  def to_expression(nil), do: "NULL"
  def to_expression(true), do: "true"
  def to_expression(false), do: "false"
  def to_expression(atom), do: atom |> Atom.to_string() |> SqlFmt.Utils.in_string_quotes()

  def to_string_literal(nil), do: "NULL"
  def to_string_literal(true), do: "true"
  def to_string_literal(false), do: "false"
  def to_string_literal(atom), do: Atom.to_string(atom)
end

defimpl SqlFmt.PrintableParameter, for: Map do
  def to_expression(map) do
    map |> to_string_literal() |> SqlFmt.Utils.in_string_quotes()
  end

  def to_string_literal(map), do: Jason.encode!(map)
end

if Code.ensure_loaded?(Geo.Point) do
  defimpl SqlFmt.PrintableParameter, for: Geo.Point do
    def to_expression(point) do
      point |> to_string_literal() |> SqlFmt.Utils.in_string_quotes()
    end

    def to_string_literal(point), do: Jason.encode!(point)
  end
end

if Code.ensure_loaded?(Geo.Polygon) do
  defimpl SqlFmt.PrintableParameter, for: Geo.Polygon do
    def to_expression(point) do
      point |> to_string_literal() |> SqlFmt.Utils.in_string_quotes()
    end

    def to_string_literal(point), do: Jason.encode!(point)
  end
end

defimpl SqlFmt.PrintableParameter, for: Tuple do
  def to_expression(tuple) do
    case to_string_literal(tuple) do
      nil ->
        "ROW(" <>
          Enum.map_join(
            Tuple.to_list(tuple),
            ",",
            &SqlFmt.PrintableParameter.to_expression/1
          ) <> ")"

      value ->
        SqlFmt.Utils.in_string_quotes(value)
    end
  end

  def to_string_literal(tuple) do
    case SqlFmt.Utils.all_to_string_literal(Tuple.to_list(tuple)) do
      :error ->
        nil

      {:ok, list} ->
        body =
          Enum.map_join(list, ",", fn {element, string_literal} ->
            case element do
              nil ->
                ""

              "" ->
                ~s|""|

              _ ->
                string = String.replace(string_literal, "\"", "\\\"")

                if String.contains?(string, [",", "(", ")"]) do
                  ~s|"#{string}"|
                else
                  string
                end
            end
          end)

        "(" <> body <> ")"
    end
  end
end

defimpl SqlFmt.PrintableParameter, for: Decimal do
  def to_expression(decimal), do: to_string_literal(decimal)
  def to_string_literal(decimal), do: Decimal.to_string(decimal)
end

defimpl SqlFmt.PrintableParameter, for: Integer do
  def to_expression(integer), do: to_string_literal(integer)
  def to_string_literal(integer), do: Integer.to_string(integer)
end

defimpl SqlFmt.PrintableParameter, for: Float do
  def to_expression(float), do: to_string_literal(float)
  def to_string_literal(float), do: Float.to_string(float)
end

defimpl SqlFmt.PrintableParameter, for: Date do
  def to_expression(date) do
    date
    |> to_string_literal()
    |> SqlFmt.Utils.in_string_quotes()
  end

  def to_string_literal(date), do: Date.to_string(date)
end

defimpl SqlFmt.PrintableParameter, for: DateTime do
  def to_expression(date_time) do
    date_time
    |> to_string_literal()
    |> SqlFmt.Utils.in_string_quotes()
  end

  def to_string_literal(date_time), do: DateTime.to_string(date_time)
end

defimpl SqlFmt.PrintableParameter, for: NaiveDateTime do
  def to_expression(naive_date_time) do
    naive_date_time
    |> to_string_literal()
    |> SqlFmt.Utils.in_string_quotes()
  end

  def to_string_literal(naive_date_time), do: NaiveDateTime.to_string(naive_date_time)
end

defimpl SqlFmt.PrintableParameter, for: Time do
  def to_expression(time) do
    time
    |> to_string_literal()
    |> SqlFmt.Utils.in_string_quotes()
  end

  def to_string_literal(time), do: Time.to_string(time)
end

defimpl SqlFmt.PrintableParameter, for: BitString do
  def to_expression(binary) do
    if String.valid?(binary) do
      SqlFmt.Utils.in_string_quotes(binary)
    else
      "DECODE('#{Base.encode64(binary)}','BASE64')"
    end
  end

  def to_string_literal(binary) do
    if String.valid?(binary) do
      binary
    end
  end
end

defimpl SqlFmt.PrintableParameter, for: List do
  def to_expression(list) do
    case to_string_literal(list) do
      nil ->
        "ARRAY[" <>
          Enum.map_join(list, ",", &SqlFmt.PrintableParameter.to_expression/1) <> "]"

      value ->
        SqlFmt.Utils.in_string_quotes(value)
    end
  end

  def to_string_literal(list) do
    case SqlFmt.Utils.all_to_string_literal(list) do
      :error ->
        nil

      {:ok, elements_with_string_literals} ->
        if tsvector?(list) do
          Enum.map_join(elements_with_string_literals, " ", fn {_element, string_literal} ->
            string_literal
          end)
        else
          body =
            Enum.map_join(elements_with_string_literals, ",", fn {element, string_literal} ->
              cond do
                is_list(element) or is_nil(element) ->
                  string_literal

                element == "" ->
                  ~s|""|

                true ->
                  string = String.replace(string_literal, "\"", "\\\"")

                  if String.downcase(string) == "null" or
                       String.contains?(string, [",", "{", "}"]) do
                    ~s|"#{string}"|
                  else
                    string
                  end
              end
            end)

          "{" <> body <> "}"
        end
    end
  end

  # tsvector is a list of lexemes.
  # By checking only the first element we assume that the others are also lexemes.
  defp tsvector?([%{__struct__: Postgrex.Lexeme} | _]) do
    true
  end

  defp tsvector?(_list) do
    false
  end
end

if Code.ensure_loaded?(Postgrex.MACADDR) do
  defimpl SqlFmt.PrintableParameter, for: Postgrex.MACADDR do
    def to_expression(macaddr) do
      macaddr
      |> to_string_literal()
      |> SqlFmt.Utils.in_string_quotes()
    end

    def to_string_literal(macaddr) do
      macaddr.address
      |> Tuple.to_list()
      |> Enum.map_join(":", fn value ->
        value
        |> Integer.to_string(16)
        |> String.pad_leading(2, "0")
      end)
    end
  end
end

if Code.ensure_loaded?(Postgrex.Interval) do
  defimpl SqlFmt.PrintableParameter, for: Postgrex.Interval do
    def to_expression(struct),
      do: Postgrex.Interval.to_string(struct) |> SqlFmt.Utils.in_string_quotes()

    def to_string_literal(struct),
      do: Postgrex.Interval.to_string(struct)
  end
end

if Code.ensure_loaded?(Postgrex.INET) do
  defimpl SqlFmt.PrintableParameter, for: Postgrex.INET do
    def to_expression(inet) do
      inet
      |> to_string_literal()
      |> SqlFmt.Utils.in_string_quotes()
    end

    def to_string_literal(inet) do
      netmask =
        case inet.netmask do
          nil -> ""
          netmask -> "/#{netmask}"
        end

      "#{:inet.ntoa(inet.address)}#{netmask}"
    end
  end
end

if Code.ensure_loaded?(Postgrex.Lexeme) do
  defimpl SqlFmt.PrintableParameter, for: Postgrex.Lexeme do
    def to_expression(lexeme) do
      raise "Invalid parameter: #{lexeme} must be inside a list"
    end

    def to_string_literal(lexeme) do
      word =
        if String.contains?(lexeme.word, [",", "'", " ", ":"]) do
          SqlFmt.Utils.in_string_quotes(lexeme.word)
        else
          lexeme.word
        end

      case lexeme.positions do
        [] ->
          word

        positions ->
          positions =
            Enum.map_join(positions, ",", fn {position, weight} ->
              if weight in [nil, :D] do
                Integer.to_string(position)
              else
                [Integer.to_string(position), Atom.to_string(weight)]
              end
            end)

          "#{word}:#{positions}"
      end
    end
  end
end
