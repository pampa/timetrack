Sequel.migration do
 up do
   alter_table(:invoices) do
     set_column_type :paid, :Integer
   end
 end

 down do
   alter_table(:invoices) do
     set_column_type :paid, :Bool
   end
 end
end
