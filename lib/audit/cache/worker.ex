# defmodule Audit.Cache.Worker do
#   use GenServer
#   require Logger
#   require Audit.Cache.Model
  
#   def start_link(otps \\ []) do
#     GenServer.start_link(__MODULE__, [], otps)
#   end

#   def init(state) do
#     :ets.new(:user, [:set, :named_table, read_concurrency: true])
#     :ets.new(:admin, [:set, :named_table, read_concurrency: true])
#     {:ok, state}
#   end

#   def lookup(table, key) when is_atom(table) do
#     case :ets.lookup(table, key) do
#       [{^key, bucket}] -> {:ok, bucket}
#       [] -> :error
#     end
#   end

#   def create(pid, table, key, data) do
#     GenServer.cast(pid, {:create, table, key, data})
#   end

#   def stop(pid) do
#     GenServer.stop(pid)
#   end

#   def handle_cast({:create, table, key, data}, state) do
#     case lookup(table, key) do
#       {:ok, _pid} ->
#         {:noreply, state}
#       :error ->
#         :ets.insert(table, {key, data})
#         {:noreply, state}
#     end
#   end
# end