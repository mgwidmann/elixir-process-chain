Chain
=====

Will spawn the number of processes asked and have them all pass a single message serially between themselves.

## Running

Start up iex:

    iex -S mix

Run with any given number:

    iex> Chain.run(1000)
    {7432, "Result is 1000"}
    :ok

The number which you passed in comes back in a string to prove that your process received the final message.

The time reported in the first portion of the tuple is in microseconds. This particular result shows creating
1,000 processes and starting with the first process with 0 as the start value, adding one to the
number received as a message and passing that result to the next process in the chain.
That took 7,432 microseconds or **7.4 milliseconds**!


## Running a large number of processes (260k+)

The Erlang VM attempts to protect you from runaway process creation. In a real world scenario, this protects from unnecessarily using up too many resources. To override this behavior, we have to set that number higher. Simply start iex with the following command:

    iex -erl "+P 10000000" -S mix

    iex>Chain.run(10_000_000)
    {102169594, "Result is 10000000"}
    :ok

102169594 microseconds is approximately 1.7 minutes.

Running without iex is approximately the same time:

    $ ELIXIR_ERL_OPTIONS="+P 10000000" mix run -e "Chain.run(10_000_000)"
    {102593788, "Result is 10000000"}


# Results on My Machine

Below I show using an .exs extension, Elixir's scripting format. Below are my machine's specs, though I suspect since the logic is all pretty much serial, more cores would not make any effect.

### iMac 2013 3.5GHz Intel Quad Core i7 w/ hyperthreading (8 CPUs) 8 GB RAM

    $ time elixir -r chain.exs -e "Chain.run(1)"
    {3967, "Result is 1"}
    elixir -r chain.exs -e "Chain.run(1)"  0.23s user 0.09s system 124% cpu 0.264 total

Most of the above time is loading of the VM, interpreting the .exs file as well as the -e parameter.
Time result in printout is in microseconds, 3967 is 0.003967 seconds


    $ time elixir -r chain.exs -e "Chain.run(100)"
    {4574, "Result is 100"}
    elixir -r chain.exs -e "Chain.run(100)"  0.23s user 0.09s system 125% cpu 0.258 total

Nearly no time difference and a factor of 100 times increase in work. Time result in printout is in microseconds, 4574 is 0.004574 seconds


    $ time elixir -r chain.exs -e "Chain.run(10_000)"
    {79202, "Result is 10000"}
    elixir -r chain.exs -e "Chain.run(10_000)"  0.28s user 0.14s system 127% cpu 0.331 total

Still no real time difference. 0.23s vs 0.28s difference is all non-deterministic system load.
Time result in printout is in microseconds, 79202 is 0.079202 seconds


    $ time elixir -r chain.exs -e "Chain.run(100_000)"
    {753390, "Result is 100000"}
    elixir -r chain.exs -e "Chain.run(100_000)"  0.77s user 0.66s system 139% cpu 1.021 total

Now it starts to show some increase in time. Time result in printout is in microseconds, 753390 is 0.75339 seconds


    $ time elixir -r chain.exs -e "Chain.run(250_000)"
    {1887977, "Result is 250000"}
    elixir -r chain.exs -e "Chain.run(250_000)"  1.66s user 1.55s system 147% cpu 2.166 total

Time result in printout is in microseconds, 1887977 is 1.887977 seconds


    $ time elixir -r chain.exs -e "Chain.run(1_000_000)" --erl "+P 1000000"
    {6166674, "Result is 1000000"}
    elixir -r chain.exs -e "Chain.run(1_000_000)" --erl "+P 1000000"  4.29s user 3.90s system 126% cpu 6.456 total

A little more than 6 seconds to boot up one million processes.
Time result in printout is in microseconds, 6166674 is 6.16667 seconds.

    $ time elixir -r chain.exs -e "Chain.run(10_000_000)" --erl "+P 10000000"
    {105322568, "Result is 10000000"}
    elixir -r chain.exs -e "Chain.run(10_000_000)" --erl "+P 10000000"  70.69s user 56.61s system 120% cpu 1:45.73 total

Still impressive. In just over 1 minute, the Erlang VM booted up, interpreted our code, spawned **10,000,000** processes, passed a message to each process **serially** and exited.
