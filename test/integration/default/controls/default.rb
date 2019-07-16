['/home/ubuntu/.bashrc', '/home/ubuntu/.bash_profile'].each do |filename|
  describe file(filename) do
    it { should exist }
  end
end

describe directory('/etc/sudoers.d') do
  it { should exist }
end

packages = yaml(content: inspec.profile.file('packages.yml')).params

packages.each do |pkg|
  describe package(pkg) do
    it { should be_installed }
  end
end

['apt-daily.service', 'apt-daily.timer'].each do |service|
  describe systemd_service(service) do
    it { should_not be_running }
  end
end

describe file('/usr/local/bin/packer') do
  it { should exist }
  it { should be_executable }
end
