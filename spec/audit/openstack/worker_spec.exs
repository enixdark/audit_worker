defmodule Audit.Openstack.WorkerSpec do
  use ESpec
  import Mock

  require Logger

  subject(shared.answer)


  before do
    {:ok, answer} = Audit.Openstack.Worker.start_link []
    {:ok, engine} = Audit.Storage.Worker.start_link
    {:shared, answer: {answer, engine}} #saves {:key, :value} to `shared`
  end

  context "Defines context" do
    subject(shared.answer)

    it "test with start link" do
      {pid, module_pid} = shared.answer
      expect(pid) |> to(be_truthy)
    end

    describe "is an alias for context" do

      it "find and update data from db" do
        uri = Application.get_env(:audit, :openstack_uri)
        {pid , module_pid} = shared.answer

        with_mock(Audit.Openstack.Process, [start_link: fn() -> {:ok, module_pid} end,
                                            fetch: fn(pid, module, ref) -> {:ok, %HTTPoison.Response{body: "{\"users\":[{\"username\":\"user\",\"enabled\":true,\"id\":\"2222\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1111\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"}]",
          headers: [{"Server", "nginx"}, {"Date", "Fri, 17 Jun 2016 09:08:23 GMT"}, {"Content-Type", "application/json"}, {"Content-Length", "835212"}, {"Connection", "keep-alive"}], 
          status_code: 200}} end]) do
          {:ok, %HTTPoison.Response{body: body}} = Audit.Openstack.Worker.fetch(pid, Audit.Storage.Worker, module_pid)
        end
      end

      it "find and update data from db" do
        uri = Application.get_env(:audit, :openstack_uri)
        {pid , module_pid} = shared.answer
        with_mock(Audit.Openstack.Process, [start_link: fn() -> {:ok, module_pid} end,
                                            update: fn(pid, module, ref) -> {:ok, %HTTPoison.Response{body: "{\"users\":[{\"username\":\"user\",\"enabled\":true,\"id\":\"2222\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1111\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"},{\"username\":\"user\",\"enabled\":true,\"id\":\"1\",\"name\":\"user\"}]",
          headers: [{"Server", "nginx"}, {"Date", "Fri, 17 Jun 2016 09:08:23 GMT"}, {"Content-Type", "application/json"}, {"Content-Length", "835212"}, {"Connection", "keep-alive"}], 
          status_code: 200}} end]) do 
          Audit.Openstack.Worker.update(pid, Audit.Storage.Worker, module_pid)
        end
      end
    end
  end
end
