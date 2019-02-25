defmodule MoodleLib.Client.Cohorts do
  alias MoodleLib.Client.Common

  def get_cohort(id) do
    %{"cohortids[0]" => id}
    |> Map.put(:wsfunction, :core_cohort_get_cohorts)
    |> Common.build_uri()
    |> HTTPoison.get!()
    |> process_got_cohort()
  end

  def create_cohort(params) do
    params
    |> Map.put("categorytype][type", "system")
    |> Map.put("categorytype][value", "ignored")
    |> Enum.map(fn {k, v} -> {"cohorts[0][#{k}]", v} end)
    |> Map.new()
    |> Map.put(:wsfunction, :core_cohort_create_cohorts)
    |> Common.build_uri()
    |> HTTPoison.get!()
    |> process_created_cohort()
  end

  def delete_cohort(id) do
    %{"cohortids[0]" => id}
    |> Map.put(:wsfunction, :core_cohort_delete_cohorts)
    |> Common.build_uri()
    |> HTTPoison.get!()
    |> process_cohort_deleted()
  end

  defp process_got_cohort(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      [%{} = cohort] ->
        {:ok, cohort}

      [] ->
        {:error, message: "Cohort not found"}
    end
  end

  defp process_created_cohort(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      [%{} = cohort] ->
        {:ok, cohort}

      %{message: message} ->
        {:error, message: message}
    end
  end

  defp process_cohort_deleted(%HTTPoison.Response{body: body}) do
    parsed_body = body |> Jason.decode!(keys: :atoms)

    case parsed_body do
      nil ->
        {:ok, message: "Cohort successfully deleted"}

      _ ->
        {:error, message: "Error deleting the cohort"}
    end
  end
end
