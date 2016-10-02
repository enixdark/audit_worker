defmodule Audit.Storage.WorkerSpec do
  use ESpec
  require Logger
  subject(shared.answer)


  before do
    answer = Audit.Storage.Worker.start_link
    {:shared, answer: answer} #saves {:key, :value} to `shared`
  end

  context "Defines context" do
    subject(shared.answer)

    it "test with start link" do
      {:ok, pid} = shared.answer
      expect(pid) |> to(be_truthy)
    end

    describe "is an alias for context" do
      before do
        {:ok,pid} = shared.answer
        {:shared, pid: pid}
      end

      # let :val, do: shared.new_answer

      it "find and update data from db" do
        data = Audit.Storage.Worker.find shared.pid
        expect data |> to_not(be_empty)
        first_data = Enum.at(data,0)
        new_data = Map.put(first_data, :email, "test@example.com")
        Audit.Storage.Worker.update(shared.pid, %{email: first_data[:email]}, new_data)
        new_first_data = Enum.at(data,0)
        Logger.info inspect(new_first_data)
        expect new_first_data[:email] |> to(eq "test@example.com")
      end
    end
  end

end
