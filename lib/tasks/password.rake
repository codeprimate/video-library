namespace :admin do
  namespace :password do
    require 'yaml'
    
    desc "Set/Reset Password"
    task :set => :environment do
      if ((ENV["user"] || '').length > 0 && (ENV["password"] || '').length > 0)
        require 'super_simple_auth'
        include SuperSimpleAuth
        set_password!(ENV["user"], ENV["password"])
        puts "Password for #{ENV["user"]} was set."
      else
        puts "Please specify user=foo and password=foo with command"
      end
    end
    
  end
end