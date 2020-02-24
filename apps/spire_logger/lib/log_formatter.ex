defmodule Spire.LogFormatter do
  @moduledoc """
  Documentation for `Spire.LogFormatter`.
  """
  @remove_keys [
    :application,
    :module,
    :line,
    :file,
    :function,
    :pid,
    :registered_name,
    :domain,
    :request_id,
    :mfa,
    :gl,
    :time,
    :ansi_color
  ]

  def format(level, message, timestamp, metadata) do
    "#{fmt_timestamp(timestamp)} [#{level}] #{message}\n\t#{fmt_metadata(metadata)}\n"
  rescue
    error ->
      IO.inspect(error)
      "could not format message: #{inspect({level, message, timestamp, metadata})}\n"
  end

  defp fmt_timestamp({date, {hh, mm, ss, ms}}) do
    with {:ok, timestamp} <- NaiveDateTime.from_erl({date, {hh, mm, ss}}, {ms * 1000, 3}),
      result <- NaiveDateTime.to_iso8601(timestamp)
    do
      "#{result}Z"
    end
  end

  defp fmt_metadata(md) do
    md
    |> Keyword.keys()
    |> Enum.map(fn key ->
      if Enum.member?(@remove_keys, key) do
        nil
      else
        "#{key}=#{inspect(md[key])}"
      end
    end)
    |> Enum.filter(fn data ->
      data != nil
    end)
    |> Enum.join(" ")
  end
end
