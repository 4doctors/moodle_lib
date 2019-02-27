defmodule MoodleLib.Client.Cohorts do
  import MoodleLib.Client.Common, only: [process_request: 2]

  def get_cohort(id) do
    %{"cohortids[0]" => id}
    |> process_request(:core_cohort_get_cohorts)
    |> handle_got_cohort()
  end

  def create_cohort(params) do
    params
    |> Map.put("categorytype][type", "system")
    |> Map.put("categorytype][value", "ignored")
    |> Enum.map(fn {k, v} -> {"cohorts[0][#{k}]", v} end)
    |> Map.new()
    |> process_request(:core_cohort_create_cohorts)
    |> handle_created_cohort()
  end

  def delete_cohort(id) do
    %{"cohortids[0]" => id}
    |> process_request(:core_cohort_delete_cohorts)
    |> handle_cohort_deleted()
  end

  def get_cohort_members(id) do
    %{"cohortids[0]" => id}
    |> process_request(:core_cohort_get_cohort_members)
    |> handle_got_cohort_members()
  end

  def add_user_to_cohort(cohort, user) do
    %{
      "members[0][cohorttype][type]" => "id",
      "members[0][cohorttype][value]" => cohort.id,
      "members[0][usertype][type]" => "id",
      "members[0][usertype][value]" => user.id
    }
    |> process_request(:core_cohort_add_cohort_members)
    |> handle_added_cohort_member(cohort.id)
  end

  def remove_user_from_cohort(cohort, user) do
    %{
      "members[0][cohortid]" => cohort.id,
      "members[0][userid]" => user.id
    }
    |> process_request(:core_cohort_delete_cohort_members)
    |> handle_removed_cohort_member(cohort.id)
  end

  defp handle_added_cohort_member(response_body, cohort_id) do
    case response_body do
      %{warnings: []} ->
        get_cohort_members(cohort_id)

      %{warnings: [%{warningcode: "3"}]} ->
        get_cohort_members(cohort_id)

      %{warnings: [%{warningcode: "2", message: message}]} ->
        {:error, message: message}
    end
  end

  defp handle_removed_cohort_member(response_body, cohort_id) do
    case response_body do
      nil ->
        get_cohort_members(cohort_id)

      _ ->
        {:error, message: "Error removing the user from the cohort"}
    end
  end

  defp handle_got_cohort(response_body) do
    case response_body do
      [%{} = cohort] ->
        {:ok, cohort}

      [] ->
        {:error, message: "Cohort not found"}
    end
  end

  defp handle_got_cohort_members(response_body) do
    case response_body do
      [%{cohortid: _id, userids: users}] ->
        {:ok, users}

      %{message: message} ->
        {:error, message: message}
    end
  end

  defp handle_created_cohort(response_body) do
    case response_body do
      [%{} = cohort] ->
        {:ok, cohort}

      %{message: message} ->
        {:error, message: message}
    end
  end

  defp handle_cohort_deleted(response_body) do
    case response_body do
      nil ->
        {:ok, message: "Cohort successfully deleted"}

      _ ->
        {:error, message: "Error deleting the cohort"}
    end
  end
end
