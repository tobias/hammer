# A sample Guardfile
# More info at https://github.com/guard/guard#readme

guard :rspec, cmd: 'bundle exec rspec' do
  watch(%r{^spec/.+_spec\.rb$}) 
  watch(%r{^lib/hammer\.rb$}) { "spec" }
  watch(%r{^lib/hammer/(.+)\.rb$})     { |m| "spec/#{m[1]}_spec.rb" }
  watch(%r{^lib/hammer/hamster_ext/(.+)\.rb$})     { |m| "spec/hamster_ext_spec.rb" }
  watch('spec/spec_helper.rb')  { "spec" }
end

