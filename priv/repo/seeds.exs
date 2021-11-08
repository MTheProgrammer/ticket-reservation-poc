# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     Tipay.Repo.insert!(%Tipay.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias Tipay.Repo
alias Tipay.Vendors
alias Tipay.VendorsTpay

Repo.delete_all(Tipay.Vendors.Vendor)

case Vendors.create_vendor(%{
       name: "Default Vendor",
       address: "Default address",
       opening_hours: "12:00-23:00",
       description: "Lorem Ipsum",
       active: true
     }) do
  {:ok, vendor} ->
    VendorsTpay.update_or_create_vendor_credentials(vendor, %{
      api_key: System.get_env("TPAY_API_KEY"),
      api_password: System.get_env("TPAY_API_PASSWORD"),
      merchant_id: System.get_env("TPAY_MERCHANT_ID")
    })

  {:error, %Ecto.Changeset{} = changeset} ->
    errors =
      Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
        Enum.reduce(opts, msg, fn {key, value}, acc ->
          String.replace(acc, "%{#{key}}", to_string(value))
        end)
      end)
      |> Enum.map_join(", ", fn {key, val} -> ~s{"#{key}: #{val}"} end)

    raise "Failed to create default vendor: " <> errors
end
