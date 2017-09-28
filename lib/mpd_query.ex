defmodule MPDQuery do
  defp connected_to_mpd(port) do
    {:ok, socket} = :gen_tcp.connect('localhost', port, [:binary, active: false])
    _ = :gen_tcp.recv(socket, 0)

    # RECVで使うバッファのサイズ指定 now(10^8)
    # :ok = :inet.setopts(socket, recbuf: 100000000)
    socket
  end

  defp map_in_list_merge(list) do
    if list |> Enum.count > 1 do
      list
        |> Enum.at(0)
        |> Map.merge(map_in_list_merge(list |> Enum.drop(1)))
    else
      list |> Enum.at(0)
    end
  end

  def to_map(data) do
    Regex.split(~r/\n/, data)
      |> Enum.map(&(Regex.split(~r/:\s/, &1)))
      |> Enum.map(&(%{String.to_atom(Enum.at(&1,0)) => Enum.at(&1,1)}))
  end

  def current do
    cmd_do("currentsong \n")
      |> map_in_list_merge
  end

  def database_list do
    MPDQuery.cmd_do("list MPD \n")
  end

  def list_all do
    cmd_do("listall \/\n")
  end

  def list_all_file do
    MPDQuery.list_all()
      |> Enum.partition(&(&1 |> Map.has_key?(:file)))
      |> elem(0)
      |> Enum.map(&(&1[:file]))
  end

  def list_all_dir do
    MPDQuery.list_all()
      |> Enum.partition(&(&1 |> Map.has_key?(:directory)))
      |> elem(0)
      |> Enum.map(&(&1[:directory]))
  end

  def ls(dir_name) do
    cmd_do(~s(lsinfo #{dir_name} \n))
      |> Enum.partition(&(&1 |> Map.has_key?(:directory)))
      |> elem(0)
      |> Enum.map(&(&1[:directory]))
  end

  def stats do
    cmd_do(~s(stats \n))
      |> map_in_list_merge
  end

  def status do
    cmd_do(~s(status \n))
      |> map_in_list_merge
  end

  def list_all_info do
    cmd_do(~s(listallinfo \n))
  end

  def cmd_do(cmd) do
    sock = connected_to_mpd(6600)


    :ok = :gen_tcp.send(sock, cmd)
    :timer.sleep(10)
    {:ok, msg} = :gen_tcp.recv(sock, 0)

    :ok = :gen_tcp.close(sock)

    # IO.puts msg

    Enum.join(for <<c::utf8 <- msg>>, do: <<c::utf8>>)
      |> to_map
 end
end

# IO.inspect MPDQuery.current
# IO.inspect MPDQuery.status
# MPDQuery.list_all |> Enum.map(&(&1 |> IO.inspect))
# IO.inspect MPDQuery.stats
# IO.inspect MPDQuery.list_all_file
# IO.inspect MPDQuery.list_all_dir
# IO.inspect MPDQuery.ls("/home/kokoax/Music/ADAM at")
IO.inspect MPDQuery.lsinfo("")
# MPDQuery.cmd_do("playlistinfo\n") |> Enum.map(&(&1 |> IO.inspect))
# MPDQuery.cmd_do("playlistid 185\n") |> Enum.map(&(&1 |> IO.inspect))
# MPDQuery.cmd_do("playlistinfo 43\n") |> Enum.map(&(&1 |> IO.inspect))
# MPDQuery.cmd_do("list\n") |> Enum.map(&(&1 |> IO.inspect))
# MPDQuery.cmd_do(~s/playlistinfo 0\n/) |> Enum.map(&(&1 |> IO.inspect))
# IO.inspect MPDQuery.cmd_do(~s/playlistinfo\n/)
# IO.inspect MPDQuery.cmd_do(~s/status\n/)
# MPDQuery.cmd_do(~s/list album\n/) |> Enum.map(&(&1 |> IO.inspect))
# MPDQuery.cmd_do("find album net_presents\n") |> Enum.map(&(&1 |> IO.inspect))


# TODO
# any query implementation

