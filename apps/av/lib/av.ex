defmodule Av do
  @moduledoc"""
  Core library
  Currently just for interacting with node application
  """
  require Poison
  require HTTPoison
  alias Porcelain.Process, as: Proc
  alias HTTPoison.Response, as: Resp

  @root_url "http://localhost:5555"
  @nodeapp __DIR__ <> "/../../../../nodeapp"

  def json_model, do: @nodeapp <> "/test/models.json"

  @doc"""
  Kills node process started by Porcelain
  """
  def kill_node do
    {ps, 0} = System.cmd "ps", ["-ef"]
    node_proc_pid = ps
    |> String.split("\n")
    |> Enum.find(&(Regex.match? ~r/\d node \S*nodeapp\/src\/index\.js/, &1))
    |> case do
      nil -> nil
      n_pid -> n_pid |> String.split |> Enum.at(1)
    end

    if node_proc_pid do
      System.cmd "kill", ["-9", node_proc_pid]
    end
  end

  defp node_result(pid, endpoint) when is_binary endpoint do
    receive do
      {^pid, :data, :out, log} ->
        IO.puts "Node log => #{log}"
        if log =~ "running",
          do: HTTPoison.get!(@root_url <> endpoint),
          else: node_result pid, endpoint
    after
      5_000 -> "nothing running, check the node app"
    end
  end

  @doc"""
  What to request from the node server
  Example:
  Av.request "/collection"
  Av.request "/notes"
  """
  def request!(endpoint) when endpoint in ~w(/collection /notes) do
    kill_node()

    System.put_env "NODE_ENV", "#{Mix.env}"
    cmd = "node #{@nodeapp}/src/index.js"
    opts = [out: {:send, self()}]
    proc = %Proc{pid: pid} = Porcelain.spawn_shell cmd, opts

    result = node_result pid, endpoint

    Proc.stop proc

    kill_node()

    with %Resp{body: body} <- result, do: Poison.decode! body
  end
end
