Sequel.migration do
 change do
   alter_table(:frames) do
     rename_column :project, :client
   end
 end
end
