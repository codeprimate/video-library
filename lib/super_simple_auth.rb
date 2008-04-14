# Simple Module for HTTP Auth

# Example config/passwords.yml (array of arrays with username and MD5 hashed password):
#
# --- 
# - - patrick
#   - b89e5d7db584679b13ed0b287bc87d8f
# - - admin
#   - b89e5d7db584679b13ed0b287bc87d8f
#


module SuperSimpleAuth
  require 'yaml'
  require 'digest/md5'
  
  @@auth_users = nil
  
  def authenticate
    load_auth_config unless @@auth_users
    auth_ok = false
    authenticate_or_request_with_http_basic do |user_name, password|
      if (user = @@auth_users.select{|u| u.first == user_name}.first)
        auth_ok = true if Digest::MD5.hexdigest(password).to_s == user.last
      end
    end
    return auth_ok
  end

  def load_auth_config
    password_file = "#{RAILS_ROOT}/config/passwords.yml"
    @@auth_users = YAML.load(File.read(password_file)) if File.exist?(password_file)
  end
  
end