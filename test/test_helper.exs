Enum.each(1..10000, fn _ -> Nicelb.join(:publishers, spawn(fn -> receive do end end)) end)
ExUnit.start()
