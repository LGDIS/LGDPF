class Constant < ActiveRecord::Migration
  def up
    create_table :constants, :force => true do |t|
      t.column "kind1",  :string
      t.column "kind2",  :string
      t.column "kind3",  :string
      t.column "text",   :string
      t.column "value",  :string
      t.column "_order", :integer
      t.timestamps
    end
  end

  def down
  end
end
