defmodule SqlFmt.FormatOptions do
  @moduledoc """
  These options are used to control how the SQL statement is formatted. The
  available formatting options are:

  * `:indent` – Specifies how many spaces are used for indents
    Defaults to `2`.

  * `:uppercase` – Configures whether SQL reserved words are capitalized.
    Defaults to `true`.

  * `:lines_between_queries` – Specifies how many line breaks should be
    present after a query.
    Defaults to `1`.

  * `:ignore_case_convert` – Configures whether certain strings should
    not be case converted.
    Defaults to `[]`.

  * `:dialect` -

  * `:inline` -

  * `:joins_as_top_level` -

  * `:max_inline_block` -

  * `:max_inline_arguments` -

  * `:max_inline_top_level` -
  """

  defstruct indent: 2,
            uppercase: true,
            lines_between_queries: 1,
            ignore_case_convert: [],
            dialect: :postgres,
            inline: false,
            joins_as_top_level: false,
            max_inline_block: 50,
            max_inline_arguments: nil,
            max_inline_top_level: nil

  @typedoc "The available formatting options."
  @type t :: %__MODULE__{
          indent: non_neg_integer(),
          uppercase: boolean(),
          lines_between_queries: non_neg_integer(),
          ignore_case_convert: list(String.t()),
          dialect: :generic | :postgres | :sql_server,
          inline: boolean,
          joins_as_top_level: boolean(),
          max_inline_block: non_neg_integer(),
          max_inline_arguments: non_neg_integer() | nil,
          max_inline_top_level: non_neg_integer | nil
        }

  @doc """
  Create an instance of the `FormatOptions` struct.
  """
  @spec new(keyword) :: t
  def new(opts \\ []) do
    struct!(__MODULE__, opts)
  end
end
