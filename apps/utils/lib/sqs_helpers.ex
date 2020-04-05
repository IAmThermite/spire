defmodule Spire.Utils.SQSUtils do
  alias ExAws.SQS

  def send_message(message) do
    SQS.send_message(Application.get_env(:utils, :sqs_queue), message, message_group_id: "SpireMessageGroup")
    |> ExAws.request()
  end
end
