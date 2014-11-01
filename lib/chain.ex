defmodule Chain do

  @doc """
    Worker function which takes in the next process to talk to in the chain as the first parameter and sends
    it the number it receives + 1.
  """
  def counter(next_pid) do
    receive do
      n ->
        send next_pid, n + 1
    end
  end

  @doc """
    Starts up n processes which passes the PID of the previously spawned process to the next process in the
    Chain.counter/1 function. Then, send the last PID a 0 message to start the chain. After, wait for the first process
    to send this PID the final answer message.
    """
  def create_processes(n) do
    # For 1 to n, starting with self as the accumulator, spawn a process and tell it to send
    # its next message to the previously spawned process
    last = Enum.reduce 1..n, self,
                fn(_n, send_to) ->
                  spawn(Chain, :counter, [send_to])
                end
    # Kick off chain of process message passing
    send last, 0

    receive do
      final_answer when is_number(final_answer) ->
        "Result is #{inspect(final_answer)}"
    end
  end

  @doc """
    Kick off the entire chaining process. TImes the call to the Chain.create_processes/1 method and prints
    the result.
    """
  def run(n) do
    IO.puts inspect :timer.tc(Chain, :create_processes, [n])
  end

end
