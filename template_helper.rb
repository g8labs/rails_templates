def remove_lines(path, flag)
  gsub_file path, flag, ''
end

def require_lib(lib, options={})
  abort('File not found.') if options[:in].blank?

  flag = case options[:in]
  when 'spec/rails_helper.rb'
    /Rails is not loaded until this point!\n/
  when 'Capfile'
    /# Include tasks from other gems included in your Gemfile\n/
  end

  insert_into_file options[:in], "require '#{lib}'\n", after: flag
end

def add_config(file, *args, &block)
  data = block_given? ? block.call : "  #{args.shift}"

  flag = case file
  when 'spec/rails_helper.rb'
    "RSpec.configure do |config|\n"
  when 'config/application.rb'
    "class Application < Rails::Application\n"
  end

  insert_into_file file, "#{data}\n", after: flag
end
