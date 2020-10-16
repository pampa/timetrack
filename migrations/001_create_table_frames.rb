Sequel.migration do
 change do
    create_table(:frames) do
      primary_key :id, :type=> Integer
      DateTime :start_time
      DateTime :end_time
      String :project
      String :tags
      String :message
      Integer :rate
    end
 end
end
