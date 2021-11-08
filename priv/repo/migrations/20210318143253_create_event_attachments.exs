defmodule Tipay.Repo.Migrations.CreateEventAttachments do
  use Ecto.Migration
  alias Tipay.EventAttachments.EventAttachment.Role

  def up do
    Role.create_type()

    create table(:event_attachments) do
      add :event_id, references(:events), null: false
      add :role, :event_attachment_role, null: false
      add :file_name, :string
      add :display_name, :string
    end

    create unique_index(:event_attachments, [:event_id],
             where: "role = 'main'",
             name: :event_attachments_main_image_unique_idx
           )

    create index(:event_attachments, [:event_id])
  end

  def down do
    drop table(:event_attachments)
    Role.drop_type()
  end
end
