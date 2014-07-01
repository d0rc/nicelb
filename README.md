Nicelb
======

Benchmarking:


```
Enum.each(1..10000, fn _ -> Nicelb.join(:publishers, spawn(fn -> receive do end end)) end)
NiceLB.Test.run
:timer.tc fn -> :rpc.pmap {NiceLB.Test, :run}, [], :lists.seq(1,100_000); :ok end
```


Motivation: there are no really fast loadbalancers for erlang. All are sloooooooow...
