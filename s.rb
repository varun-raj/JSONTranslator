require 'google/cloud/translate'

CONFIG_FILE_PATH = 'config.yaml'

class STranslator
  attr_accessor :translator, :config

  def initialize
    read_config
    set_translator
  end

  def translate!(sentence)
    config[:destination_languages].each do |lang|
      puts "\n\n---- #{lang} ----\n\n"
      value = translator.translate(sentence, to: lang)
      puts value.text
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
end
