defmodule Tipay.Repo.Migrations.CreateOfferBookings do
  use Ecto.Migration

  def change do
    create table(:offer_bookings) do
      add :offer_id, references(:offers), null: false
      add :transaction_id, references(:transactions), null: false
      add :qty, :integer, null: false
      add :price, :money_with_currency
    end

    create index(:offer_bookings, [:offer_id])
    create index(:offer_bookings, [:transaction_id])

    execute(
      # up
      ~S"""
      CREATE FUNCTION offer_bookings_limit_qty_to_offers_qty() RETURNS TRIGGER AS $$
      DECLARE
        qty_limit INTEGER;
      BEGIN
        -- select offer quantity that is left for reservation
        SELECT (o.available_qty - o.sold_qty) INTO qty_limit
          FROM offers AS o
          WHERE o.id = NEW.offer_id;
        -- reserve requested quantity or maximum available for the offer
        NEW.qty = LEAST(NEW.qty, qty_limit);
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,

      # down
      "DROP FUNCTION offer_bookings_limit_qty_to_offers_qty;"
    )

    execute(
      # up
      ~S"""
      CREATE TRIGGER offer_bookings_limit_qty_to_offers_qty_check
      BEFORE INSERT ON offer_bookings
      FOR EACH ROW
      EXECUTE PROCEDURE offer_bookings_limit_qty_to_offers_qty();
      """,

      # down
      "DROP TRIGGER offer_bookings_limit_qty_to_offers_qty_check ON offer_bookings;"
    )
  end
end
