defmodule Audit.Billing.WorkerSpec do
  use ESpec
  require Logger
  subject(shared.answer)


  before do
    {:ok, answer} = Audit.Billing.Worker.start_link([])
    {:ok, engine} = Audit.Storage.Worker.start_link
    {:shared, answer: {answer, engine}}
  end

  context "Defines context" do
    subject(shared.answer)

    it "test with start link" do
      {pid, module_pid} = shared.answer
      expect(pid) |> to(be_truthy)
    end

    describe "is an alias for context" do

    end
  end

end
