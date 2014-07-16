SETTINGS = YAML.load(ERB.new(File.read(Rails.root.join('config', 'settings.yml'))).result) [Rails.env]
