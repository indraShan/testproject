defmodule Starter do
  @moduledoc """
  This module acts as the application starter. It
  takes in arguments from the command line and passes
  it on to the next subsequent modules.

  Two arguments should be passed from command line
  N => maximum number upto which sequences to be checked
  k => sequence length

  Example:
  mix run ./lib/Starter.ex 1000000 24

  """
  use Application

  @doc """
  Starts the app by starting a supervisor and then waits
  until a :done message is received back. This ensures
  that the application does not get killed abruptly.
  """
  def start(_type, _args) do
    AppSupervisor.start_link(name: StaticAppSupervisor, application: self(), args: System.argv())
    waitForResult()
    {:ok, self()}
  end

  def waitForResult() do
    receive do
      {:done} -> IO.puts "Done"
    end
  end
end
