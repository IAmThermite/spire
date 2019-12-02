defmodule Spire.LogsTest do
  use Spire.DataCase

  alias Spire.Logs

  describe "logs" do
    alias Spire.Logs.Log

    @valid_attrs %{logfile: "some logfile", map: "some map"}
    @update_attrs %{logfile: "some updated logfile", map: "some updated map"}
    @invalid_attrs %{logfile: nil, map: nil}

    def log_fixture(attrs \\ %{}) do
      {:ok, log} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Logs.create_log()

      log
    end

    test "list_logs/0 returns all logs" do
      log = log_fixture()
      assert Logs.list_logs() == [log]
    end

    test "get_log!/1 returns the log with given id" do
      log = log_fixture()
      assert Logs.get_log!(log.id) == log
    end

    test "create_log/1 with valid data creates a log" do
      assert {:ok, %Log{} = log} = Logs.create_log(@valid_attrs)
      assert log.logfile == "some logfile"
      assert log.map == "some map"
    end

    test "create_log/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Logs.create_log(@invalid_attrs)
    end

    test "update_log/2 with valid data updates the log" do
      log = log_fixture()
      assert {:ok, %Log{} = log} = Logs.update_log(log, @update_attrs)
      assert log.logfile == "some updated logfile"
      assert log.map == "some updated map"
    end

    test "update_log/2 with invalid data returns error changeset" do
      log = log_fixture()
      assert {:error, %Ecto.Changeset{}} = Logs.update_log(log, @invalid_attrs)
      assert log == Logs.get_log!(log.id)
    end

    test "delete_log/1 deletes the log" do
      log = log_fixture()
      assert {:ok, %Log{}} = Logs.delete_log(log)
      assert_raise Ecto.NoResultsError, fn -> Logs.get_log!(log.id) end
    end

    test "change_log/1 returns a log changeset" do
      log = log_fixture()
      assert %Ecto.Changeset{} = Logs.change_log(log)
    end
  end
end
