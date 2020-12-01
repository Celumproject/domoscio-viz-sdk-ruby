DomoscioViz.configure do |c|
    if Rails.env == "production"
        c.preproduction = true
    else
        c.preproduction = false
    end
    c.client_id = ENV['DOMOSCIO_ID']
    c.client_passphrase = ENV['DOMOSCIO_PASSWORD']
    c.temp_dir = File.expand_path('../tmp', __FILE__)
    FileUtils.mkdir_p(c.temp_dir) unless File.directory?(c.temp_dir)
end