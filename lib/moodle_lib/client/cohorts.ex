defmodule MoodleLib.Client.Cohorts do
  alias MoodleLib.Client.Common

  def get_cohort(id) do
    %{"cohortids[0]" => id}
    |> Map.put(:wsfunction, :core_cohort_get_cohorts)
    |> Common.build_uri()
    |> HTTPoison.get!()
    |> process_got_cohort()
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
end
