# encoding: utf-8
class AlterSheltersIndex < ActiveRecord::Migration
  def change
    ActiveRecord::Base.connection.execute("drop index index_shelters_on_name")
    add_index(:shelters, [:name, :record_mode], :unique => true, :where => 'deleted_at is NULL')
  end
end
