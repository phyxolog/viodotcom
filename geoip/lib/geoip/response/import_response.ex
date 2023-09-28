defmodule GeoIP.ImportResponse do
  @moduledoc false

  @derive Jason.Encoder

  @type t() :: %GeoIP.ImportResponse{
          total: non_neg_integer(),
          imported: non_neg_integer(),
          discarded: non_neg_integer()
        }

  defstruct [:total, :imported, :discarded]
end
