class CreateIdempotentActions < ActiveRecord::Migration[7.0]
  def change
    create_table :idempotent_actions do |t|
      t.string :idempotency_key, null: false, index: {unique: true}

      t.timestamps
    end
  end
end
