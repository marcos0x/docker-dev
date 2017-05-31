namespace :first_store do
  desc "Creates first store"
  task :create => :environment do
    tenant = 'docker-deploy'
    exist = Spree::Store.find_by(code: tenant)

    unless exist
      provincia = Spree::Country.find_by(name: 'MENDOZA')
      departamento = Spree::Country.find_by(name: 'MENDOZA').states.find_by(name: "MENDOZA (5500)")

      store_attrs = {
        name: 'Docker Deploy',
        email: 'docker.deploy@tween.com.ar',
        firstname: 'Docker',
        lastname: 'Deploy',
        tenant: tenant,
        country: provincia,
        state: departamento
      }

      st = Store.new(store_attrs)
      st.save
    end
  end
end

