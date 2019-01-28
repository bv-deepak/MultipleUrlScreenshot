PUPPETEER = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/puppeteer.yml")).result)[Rails.env]
