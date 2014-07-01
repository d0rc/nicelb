defmodule NicelbTest.TestServer do
	use ExActor.GenServer

	definit do
		Nicelb.join(:publishers, self)
		{:ok, []}
	end
	defcall testcall(val) do
		reply {:ok, val}
	end
end


Enum.each(1..10000, fn _ -> NicelbTest.TestServer.start end)
:timer.sleep(:timer.seconds(1))
ExUnit.start()
