namespace :freeze do
  task :matthewrudy => :environment do
    require 'open-uri'
    gravatar = open("http://www.gravatar.com/avatar/e60b2dc57668b5662ce3f07781e41710?s=400")
  
    File.open(File.join(Rails.root, "public", "matthewrudy.jpg"), "w") do |out|
      out.puts gravatar.read
    end
  end
end
