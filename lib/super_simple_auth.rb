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
  
  PASSWORD_FILE = "#{RAILS_ROOT}/config/passwords.yml"
  
  @@auth_users = nil
  
  def authenticate
    load_auth_config unless @@auth_users
    auth_ok = false
    authenticate_or_request_with_http_basic do |user_name, password|
      if (user = @@auth_users.select{|u| u.first == user_name}.first)
        auth_ok = true if hash_password(password) == user.last
      end
    end
    return auth_ok
  end

  def load_auth_config
    File.open(PASSWORD_FILE,"w").print '' unless File.exist?(PASSWORD_FILE)
    if File.exist?(PASSWORD_FILE)
      @@auth_users = YAML.load(File.read(PASSWORD_FILE)) 
      @@auth_users ||= []
      return true
    else
      raise "Password file not found => #{PASSWORD_FILE}"
    end
  end
  
  def set_password!(username, password)
    load_auth_config unless @@auth_users
    @@auth_users.reject!{|u| u.first == username} if @@auth_users
    @@auth_users << [username, hash_password(password)]
    save_data!
  end
  
  private
  
  def hash_password(password)
    return Digest::MD5.hexdigest(password).to_s
  end
  
  def save_data!
    if File.exist?(PASSWORD_FILE)
      File.open(PASSWORD_FILE, "w").puts @@auth_users.to_yaml
      return true
    else
      raise "Password file not found => #{PASSWORD_FILE}"
    end
  end
  
end