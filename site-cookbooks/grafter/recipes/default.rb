directory '/root/grafter'

cookbook_file '/root/grafter/Gemfile' do
  source 'grafter-gemfile'
end

cookbook_file '/root/.bash_aliases' do
  source 'root-bash-aliases'
end

rbenv_ruby '1.9.3-p448'

rbenv_global '1.9.3-p448'

rbenv_gem 'bundler' do
  rbenv_version '1.9.3-p448'
end

rbenv_script 'bundle_install_grafter' do
  rbenv_version '1.9.3-p448'
  user          'root'
  group         'root'
  cwd           '/root/grafter'
  code          %{bundle install --binstubs}
end
