defmodule Spire.Utils.SQSUtils do
  alias ExAws.SQS

  @sqs_queue Application.get_env(:utils, :sqs_queue)

  def send_message(message) do
    SQS.send_message(@sqs_queue, message, message_group_id: "SpireMessageGroup")
    |> ExAws.request()
  end
end
