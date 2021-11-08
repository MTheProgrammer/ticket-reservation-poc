defmodule Tipay.OffersTest do
  use Tipay.DataCase, async: true

  alias Tipay.Offers

  describe "offers" do
    alias Tipay.Offers.Offer

    test "list_offers/0 returns all offers" do
      offer = insert(:offer)
      [result_offer] = Offers.list_offers()

      assert result_offer.name == offer.name
      assert result_offer.description == offer.description
      assert result_offer.price == offer.price
      assert result_offer.sold_qty == offer.sold_qty
      assert result_offer.published_at == offer.published_at
      assert result_offer.begins_at == offer.begins_at
      assert result_offer.ends_at == offer.ends_at
      assert result_offer.status == :available
      assert not is_nil(result_offer.is_editable)
    end

    test "get_offer!/1 returns the offer with given id" do
      offer = insert(:offer)
      result_offer = Offers.get_offer!(offer.id)

      assert result_offer.name == offer.name
      assert result_offer.description == offer.description
      assert result_offer.price == offer.price
      assert result_offer.sold_qty == offer.sold_qty
      assert result_offer.published_at == offer.published_at
      assert result_offer.begins_at == offer.begins_at
      assert result_offer.ends_at == offer.ends_at
      assert result_offer.status == :available
      assert not is_nil(result_offer.is_editable)
    end

    test "create_offer/1 with valid data creates an offer" do
      event = insert(:event)
      template = build(:offer)

      offer_desc = %{
        name: template.name,
        description: template.description,
        price: template.price,
        available_qty: template.available_qty,
        sold_qty: template.sold_qty,
        published_at: template.published_at,
        ends_at: template.ends_at,
        begins_at: template.begins_at,
        event_id: event.id
      }

      assert {:ok, %Offer{} = offer} = Offers.create_offer(offer_desc)

      assert offer.name == offer_desc.name
      assert offer.description == offer_desc.description
      assert offer.price == offer_desc.price
      assert offer.available_qty == offer_desc.available_qty
      assert offer.sold_qty == offer_desc.sold_qty
      assert offer.published_at == offer_desc.published_at
      assert offer.begins_at == offer_desc.begins_at
      assert offer.ends_at == offer_desc.ends_at
      assert offer.status == :available
      assert not is_nil(offer.is_editable)
    end

    test "create_offer/1 with invalid data returns error changeset" do
      assert {:error, changeset} = Offers.create_offer(%{})

      assert %{
               event_id: ["can't be blank"],
               available_qty: ["can't be blank"],
               description: ["can't be blank"],
               name: ["can't be blank"],
               price: ["can't be blank"],
               published_at: ["can't be blank"],
               ends_at: ["can't be blank"],
               begins_at: ["can't be blank"]
             } = errors_on(changeset)
    end

    test "update_offer/2 with valid data updates the offer" do
      offer = insert(:offer)
      template = build(:offer)

      offer_desc = %{
        name: template.name,
        description: template.description,
        price: template.price,
        available_qty: template.available_qty,
        published_at: template.published_at,
        ends_at: template.ends_at,
        begins_at: template.begins_at,
        event_id: template.event.id
      }

      assert {:ok, %Offer{} = offer} = Offers.update_offer(offer, offer_desc)
      assert offer.name == offer_desc.name
      assert offer.description == offer_desc.description
      assert offer.price == offer_desc.price
      assert offer.available_qty == offer_desc.available_qty
      assert offer.published_at == offer_desc.published_at
      assert offer.begins_at == offer_desc.begins_at
      assert offer.ends_at == offer_desc.ends_at
      assert offer.status == :available
      assert not is_nil(offer.is_editable)
    end

    test "update_offer/2 with invalid data returns error changeset" do
      offer = insert(:offer)

      assert {:error, %Ecto.Changeset{}} =
               Offers.update_offer(offer, %{
                 name: nil,
                 description: nil,
                 price: nil,
                 available_qty: nil,
                 sold_qty: nil,
                 published_at: nil,
                 begins_at: nil,
                 sale_en: nil
               })
    end

    test "update_offer/2 with valid data updates only casted fields" do
      original_offer =
        insert(:offer,
          sold_qty: 1,
          published_at: ~U[2020-04-17T14:00:00.000000Z],
          begins_at: ~U[2020-05-17T14:00:00.000000Z],
          ends_at: ~U[2021-04-17T14:00:00.000000Z]
        )

      event = insert(:event)

      offer_desc = %{
        name: "lorem",
        description: "slipsum amet",
        price: 22.33,
        available_qty: 555,
        published_at: ~U[3020-04-17T14:00:00.000000Z],
        begins_at: ~U[3020-05-17T14:00:00.000000Z],
        ends_at: ~U[3021-04-17T14:00:00.000000Z],
        event_id: event.id
      }

      assert {:ok, %Offer{} = offer} = Offers.update_offer(original_offer, offer_desc)
      assert offer.name == offer_desc.name
      assert offer.description == offer_desc.description
      assert offer.available_qty == offer_desc.available_qty
      assert offer.ends_at == offer_desc.ends_at

      assert offer.price == original_offer.price
      assert offer.published_at == original_offer.published_at
      assert offer.begins_at == original_offer.begins_at
      assert offer.status == :available
      assert offer.event_id == original_offer.event_id
      assert not is_nil(offer.is_editable)
    end

    test "update_offer/2 with valid data updates only not nil fields" do
      original_offer = insert(:offer)
      event = insert(:offer)

      offer_desc = %{
        price: 22.33,
        published_at: ~U"2020-04-17T14:00:00.000000Z",
        begins_at: ~U"3020-04-17T14:00:00.000000Z",
        event_id: event.id
      }

      assert {:ok, %Offer{} = offer} = Offers.update_offer(original_offer, offer_desc)
      assert offer.name == original_offer.name
      assert offer.description == original_offer.description
      assert offer.available_qty == original_offer.available_qty
      assert offer.ends_at == original_offer.ends_at

      assert offer.price == original_offer.price
      assert offer.published_at == original_offer.published_at
      assert offer.begins_at == original_offer.begins_at
      assert offer.status == :available
      assert offer.event_id == original_offer.event_id
      assert not is_nil(offer.is_editable)
    end

    test "delete_offer/1 deletes the offer" do
      offer = insert(:offer, sold_qty: 0)
      assert {:ok, %Offer{}} = Offers.delete_offer(offer)
      assert_raise Ecto.NoResultsError, fn -> Offers.get_offer!(offer.id) end
    end

    test "delete_offer/1 prevents deleting offer with sold_qty > 0" do
      offer = insert(:offer, sold_qty: 1)
      assert {:error, %Ecto.Changeset{} = changeset} = Offers.delete_offer(offer)

      assert %{
               sold_qty: ["deleting offers with already sold items is forbidden"]
             } = errors_on(changeset)
    end

    test "change_offer/1 returns an offer changeset" do
      offer = insert(:offer)
      assert %Ecto.Changeset{} = Offers.change_offer(offer)
    end
  end

  describe "offers with sold_qty > 0" do
    alias Tipay.Offers.Offer

    test "update_offer/2 forbids decreasing available_qty below sold_qty" do
      offer = insert(:offer, available_qty: 5, sold_qty: 2)
      min_allowed = 2
      max_disallowed = min_allowed - 1

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Offers.update_offer(offer, %{available_qty: max_disallowed})

      assert %{available_qty: ["must be greater than or equal to 2 for offer with sold qty"]} =
               errors_on(error_changeset)
    end

    test "update_offer/2 allows decreasing available_qty when it is greater or equal to sold_qty" do
      offer = insert(:offer, available_qty: 120, sold_qty: 10)
      min_allowed = 10

      assert {:ok, %Offer{available_qty: ^min_allowed}} =
               Offers.update_offer(offer, %{available_qty: min_allowed})
    end
  end

  describe "offers date validation" do
    alias Tipay.Offers.Offer

    test "create offer with wrong dates returns error changeset" do
      %{id: event_id} = insert(:event)

      offer_data = %{
        available_qty: 10,
        name: "test dates",
        description: "Lorem",
        event_id: event_id,
        price: Money.new(1234),
        begins_at: ~U[2021-01-01 00:00:00Z],
        published_at: ~U[3020-01-01 00:00:00Z],
        ends_at: ~U[2019-01-01 00:00:00Z]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} = Offers.create_offer(offer_data)

      assert %{
               begins_at: ["must be earlier than ends_at"],
               published_at: ["must be earlier than begins_at"]
             } = errors_on(error_changeset)
    end

    test "update offer with wrong dates returns error changeset" do
      offer =
        insert(:offer,
          begins_at: ~U[4021-01-01 00:00:00Z]
        )

      offer_data = %{
        ends_at: ~U[4019-01-01 00:00:00Z]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Offers.update_offer(offer, offer_data)

      assert %{
               ends_at: ["must be later than begins_at for offer with sold qty"]
             } = errors_on(error_changeset)
    end

    test "update offer not yet sold with begins_at < ends_at updates offer" do
      offer = insert(:offer, sold_qty: 0, begins_at: ~U[3000-01-01 00:00:00Z])

      offer_data = %{
        begins_at: ~U[2021-07-20 08:30:42Z],
        ends_at: ~U[2021-07-29 08:30:48Z]
      }

      assert {:ok, %Offer{}} = Offers.update_offer(offer, offer_data)
    end

    test "update offer that has already sold qty and with begins_at < ends_at returns error" do
      offer = insert(:offer, sold_qty: 10, available_qty: 20, begins_at: ~U[3000-01-01 00:00:00Z])

      offer_data = %{
        begins_at: ~U[2021-07-20 08:30:42Z],
        ends_at: ~U[2021-07-29 08:30:48Z]
      }

      assert {:error, %Ecto.Changeset{} = error_changeset} =
               Offers.update_offer(offer, offer_data)

      assert %{
               ends_at: ["must be later than begins_at for offer with sold qty"]
             } = errors_on(error_changeset)
    end
  end
end
