defmodule Nicelb.Utils do
  @max 1073741824
  defmacro __using__(_) do
    quote do
      defp random_id do
        case :erlang.get(:random_seed) do
          seed when is_tuple(seed) ->
            :quickrand.uniform(unquote(@max))
          :undefined -> 3
            :quickrand.seed
            :quickrand.uniform(unquote(@max))
        end
      end
    end
  end
end

defmodule Nicelb do
  use Application
  use Nicelb.Utils

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    :ets.new :nicelb_catalogue, [:ordered_set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}]
    children = [
      worker(NiceLB.Worker, [])
    ]

    opts = [strategy: :one_for_one, name: Nicelb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  def get_members(group) do
    for {_id, p_group, pid} <- :ets.tab2list(:nicelb_catalogue), p_group == group do
      pid
    end
  end

  def get_random_pid(group), do: _get_random_pid(group)
  defp _get_random_pid(group) do
    id = case random_id do
      rid when :erlang.rem(rid, 2) == 0 -> :ets.next(:nicelb_catalogue, rid)
      rid -> :ets.prev(:nicelb_catalogue, rid)
    end
    case :ets.lookup(:nicelb_catalogue, id) do
      [{_, ^group, pid}] -> pid
      _ -> _get_random_pid(group)
    end
  end
  
  def leave(group), do: leave(group, self())
  def leave(group, pid), do: NiceLB.Worker.leave(group, pid)
  def join(group), do: join(group, self())
  def join(group, pid), do: NiceLB.Worker.join(group, pid)
end

defmodule NiceLB.Worker do
  use ExActor.GenServer, export: :nicelb_worker
  use Nicelb.Utils

  definit do
    {:ok, []}
  end
  defcall join(group, pid) do
    reply :ets.insert(:nicelb_catalogue, {random_id, group, pid})
  end
  defcall leave(group, pid) do
    (for {id, p_group, p_pid} <- :ets.tab2list(:nicelb_catalogue), p_pid == pid and p_group == group do
      true = :ets.delete :nicelb_catalogue, id
    end) |> reply
  end
end


defmodule NiceLB.Test do
  def run do
    :timer.tc fn -> Enum.each(1..1000000, fn _ -> Nicelb.get_random_pid :publishers end) end
  end
  def run(_) do
    Nicelb.get_random_pid :publishers
  end
end
