require 'json'
require 'fileutils'
require 'google/cloud/translate'
require 'active_support/all'

CONFIG_FILE_PATH = 'config.yaml'
MASK_REGEX = /\%\{[a-z\_\-]*\}/.freeze
INTP_REGEX = /\%\{([a-z\_\-]*)\}/.freeze

class LocaleTranslator
  attr_accessor :translator, :input_folder_path, :output_folder_path, :config, :current_lang

  def self.mask(value)
    masks = []
    value.scan(MASK_REGEX).each do |intp|
      mask_intp = convert_mask(intp)
      masks.push([intp, mask_intp])
      value = value.gsub(intp, mask_intp)
    end

    [value, masks]
  end

  def self.convert_mask(intp)
    mask_intp = intp.match(INTP_REGEX)
    mask_intp = mask_intp[1].to_s.parameterize.upcase
    "__#{mask_intp}__"
  end

  def self.unmask(masked_value, masks)
    masks.each do |intp, mask_intp|
      masked_value = masked_value.gsub(mask_intp, intp)
    end

    masked_value
  end

  def initialize
    read_config
    set_translator

    self.input_folder_path = '/Users/swaathi/code/work/JSONTranslator/input'
    self.output_folder_path = '/Users/swaathi/code/work/JSONTranslator/output'
  end

  def convert!
    config[:destination_languages].each do |lang|
      puts "\n\n---- Converting files to #{lang} ----\n\n"
      self.current_lang = lang

      traverse! input_folder_path
    end
  end

  def traverse!(current_path)
    Dir[File.join(current_path, "/*")].each do |path|
      if File.file?(path) && is_en?(path)
        puts "Copying and converting '#{path}' now...\n"
        copy_en_file_to_output_folder(path)

      	original_yaml = YAML.load(File.read(path))

        translated_yaml = translate(original_yaml)
        write!(path, translated_yaml)

        puts "Done!\n\n"
        sleep(1)
      elsif File.directory? path
        create_nested_output_folder(path)
        traverse!(path)
      end
    end
  end

  def translate(hash)
    hash.each do |key, value|
    	if value.is_a?(Hash)
        value = translate(value)
      else
        value, masks = LocaleTranslator.mask(value)
        value = translator.translate(value, to: current_lang)
        hash[key] = LocaleTranslator.unmask(value.text, masks)

        puts "#{key}: #{hash[key]}"
    	end
    end

    hash
  end

  def write!(input_file_path, translated_yaml)
    translated_yaml[current_lang] = translated_yaml["en"]
    translated_yaml.delete("en")

    translated_yaml = YAML.dump translated_yaml

    output_file_path = create_output_file_path(input_file_path)
    puts "\n\nWriting to #{output_file_path} now...\n\n"

  	File.open(output_file_path, "w+") do |f|
  	  f.write(translated_yaml)
  	end
  end

  private
  def read_config
    self.config = YAML.load(File.read(CONFIG_FILE_PATH))
    self.config = config.inject({}){|memo,(k,v)| memo[k.to_sym] = v; memo}
  end

  def set_translator
    creds = Google::Cloud::Translate::Credentials.new(
      self.config[:service_key_path]
    )

    # Create the instance of Google Translate API
    self.translator = Google::Cloud::Translate.new(
      project_id: self.config[:google_project_id],
      credentials: creds
    )
  end

  def current_output_folder
    # File.join(output_folder_path, current_lang)
    output_folder_path
  end

  def create_nested_output_folder(path)
    nested_output_folder_path = path.gsub(
      input_folder_path,
      output_folder_path
    )
    # nested_output_folder_path = path.gsub(
    #   input_folder_path,
    #   current_output_folder
    # )
    FileUtils.mkdir_p nested_output_folder_path
  end

  def create_output_file_path(path)
    output_file_path = path.gsub(
      input_folder_path,
      current_output_folder
    )
    output_file_path.gsub("en.yml", "#{current_lang}.yml")
  end

  def is_en?(path)
    path.include? "en.yml"
  end

  def copy_en_file_to_output_folder(path)
    if is_en?(path)
      output_en_file_path = path.gsub(
        input_folder_path,
        output_folder_path
      )
      FileUtils.cp(path, output_en_file_path)
    end
  end
end
