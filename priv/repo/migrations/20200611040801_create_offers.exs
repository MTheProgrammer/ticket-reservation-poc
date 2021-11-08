defmodule Tipay.Repo.Migrations.CreateOffers do
  use Ecto.Migration

  def change do
    create table(:offers) do
      add :name, :string, null: false
      add :description, :string
      add :price, :money_with_currency
      add :available_qty, :integer, null: false, default: 0
      add :sold_qty, :integer, null: false, default: 0
      add :published_at, :utc_datetime, null: false
      add :begins_at, :utc_datetime, null: false
      add :ends_at, :utc_datetime, null: false

      timestamps()
    end

    execute(
      # up
      ~S"""
      -- prevents reserving more offers than available
      -- reserves remaining available quantity
      CREATE FUNCTION offers_limit_sold_qty() RETURNS TRIGGER AS $$
      BEGIN
        IF NEW.sold_qty IS NOT NULL THEN
          IF (NEW.sold_qty > OLD.available_qty) THEN
            -- round down sold_qty to max available_qty
            NEW.sold_qty = OLD.available_qty;
          END IF;
        END IF;
        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql;
      """,

      # down
      "DROP FUNCTION offers_limit_sold_qty;"
    )

    execute(
      # up
      ~S"""
      CREATE TRIGGER offers_limit_sold_qty_check
      BEFORE UPDATE ON offers
      FOR EACH ROW
      EXECUTE PROCEDURE offers_limit_sold_qty();
      """,

      # down
      "DROP TRIGGER offers_limit_sold_qty_check ON offers;"
    )
  end
end
