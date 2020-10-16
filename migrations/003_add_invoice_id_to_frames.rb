Sequel.migration do
 change do
   alter_table(:frames) do
     add_column :invoice_id, Integer
   end
 end
end
