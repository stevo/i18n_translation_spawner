Gem::Specification.new do |s|
  s.name        = 'i18n_translation_spawner'
  s.version     = '0.0.17'
  s.date        = '2011-11-03'
  s.summary     = "Automatic i18n keys generator"
  s.description = "Gem for automatic creation of i18n keys in your YAML files as you develop"
  s.authors     = ["Błażej --Stevo-- Kosmowski"]
  s.email       = 'b.kosmowski@selleo.com'
  s.files       = Dir['lib/**/*.rb']
  s.add_runtime_dependency 'ya2yaml', '>= 0.3'
  s.homepage    =
    'https://github.com/stevo/i18n_translation_spawner'
end