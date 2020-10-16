Sequel.migration do
 change do
    create_table(:invoices) do
      primary_key :id, :type=> Integer
      DateTime :datetime
      String :client
      Bool :paid
      String :title
    end
 end
end
