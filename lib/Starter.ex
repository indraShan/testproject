defmodule Starter do
  use Application

  def start(_type, args) do
    AppSupervisor.start_link(name: StaticAppSupervisor, args: args)
  end
end
