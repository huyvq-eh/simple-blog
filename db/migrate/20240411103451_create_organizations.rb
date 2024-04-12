class CreateOrganizations < ActiveRecord::Migration[6.1]
  def change
    create_table :organizations do |t|
      t.string :country
      t.string :number_of_employees
      t.boolean :is_csa
      t.string :external_id

      t.timestamps
    end
  end
end
