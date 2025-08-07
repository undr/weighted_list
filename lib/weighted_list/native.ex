defmodule WeightedList.Native do
  use Rustler, otp_app: :weighted_list, crate: "weighted_list"

  # When your NIF is loaded, it will override this function.
  def setup(_values, _weights), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def get(_ref, _idx, _rng), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def index(_ref, _idx, _rng), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def size(_ref), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def values(_ref), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def aliases(_ref), do: :erlang.nif_error(:nif_not_loaded)

  # When your NIF is loaded, it will override this function.
  def probs(_ref), do: :erlang.nif_error(:nif_not_loaded)
end
