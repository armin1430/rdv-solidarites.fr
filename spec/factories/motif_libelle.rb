FactoryBot.define do
  sequence(:libelle_name) { |n| "Libellé n°#{n}" }

  factory :motif_libelle do
    name { generate(:libelle_name) }
    service { Service.first || create(:service) }
  end
end
