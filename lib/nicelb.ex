defmodule Nicelb do
  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    :ets.new :nicelb_catalogue, [:ordered_set, :public, :named_table, {:read_concurrency, true}, {:write_concurrency, true}]
    # :ets.insert :nicelb_catalogue, {-1, 1073741824}
    children = [
      # Define workers and child supervisors to be supervised
      # worker(Nicelb.Worker, [arg1, arg2, arg3])
    ]

    opts = [strategy: :one_for_one, name: Nicelb.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp random_id do
    case :erlang.get(:random_seed) do
      seed when is_tuple(seed) -> 
        :quickrand.uniform(1073741824)
      :undefined -> 3
        :quickrand.seed
        :quickrand.uniform(1073741824)
    end
  end

  @doc """
    serialize this call to ensure no overwriting....
  """
  def join(group), do: join(group, self())
  def join(group, pid) do 
    :ets.insert :nicelb_catalogue, {random_id, group, pid}
  end

  def get_members(group) do
    for {id, pid_group, pid} <- :ets.tab2list(:nicelb_catalogue), id >= 0 and pid_group == group do
      pid
    end
  end

  def get_random_pid(group), do: _get_random_pid(group)
  defp _get_random_pid(group) do
    case :ets.lookup(:nicelb_catalogue, :ets.next(:nicelb_catalogue, random_id)) do
      [{_, ^group, pid}] -> pid
      _ -> _get_random_pid(group)
    end
  end
  
  def leave(group), do: leave(group, self())
  def leave(group, pid) do
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
