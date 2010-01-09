
script_dir = File.join(node[:mysql][:root], "scripts").to_s

if node[:mysql] && node[:mysql][:instances]
  directory script_dir do
    owner "root"
    group "root"
    mode 0700
    recursive true
  end

  if node[:mysql][:perform_backups]
    package "xtrabackup"
    
    remote_file File.join(script_dir, "backup_mysql.rb") do
      source "backup_mysql.rb"
      owner "root"
      group "root"
      mode "0700"
    end
    
    template File.join(script_dir, "backup_all.sh") do
      source "backup_all.sh.erb"
      owner "root"
      group "root"
      mode "0700"    
    end
    
    cron "backup mysql databases" do
      command File.join(script_dir, "backup_all.sh")
      hour node[:mysql][:backup_hour]
      minute "00"
    end
  end
  
  node[:mysql][:instances].each do |name, instance|
    mysql_server name do
      config instance[:config]
      version instance[:version]

      if instance[:backup_location]
        backup_location instance[:backup_location]
      end
    end
  end
else
  Chef::Log.warn "You included the MySQL server recipe, but didn't specify MySQL instances"
end
