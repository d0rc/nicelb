defmodule NicelbTest do
  use ExUnit.Case

  test "can read all list" do
  	list = Nicelb.get_members(:publishers)
  	assert length(list) == 10000
  end

  test "can add/remove to different group" do
  	pid = spawn fn -> :timer.sleep(60000) end
  	assert Nicelb.join(:publishersx, pid) == true
  	assert (Nicelb.get_members(:publishersx) |> length) == 1
  	assert (Nicelb.get_members(:publishers) |> length) == 10000
  	assert (Nicelb.get_random_pid(:publishersx) == pid)
  	Nicelb.leave(:publishersx, pid)
  	assert (Nicelb.get_members(:publishersx) |> length) == 0
  end

  test "we can query pool" do
  	for i <- 1..1000 do
  		assert {:ok, i} == NicelbTest.TestServer.testcall(Nicelb.get_random_pid(:publishers), i)
  	end
  end
end
