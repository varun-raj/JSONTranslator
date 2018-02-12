# Imports the Google Cloud client library
require "google/cloud/translate"
require 'json'

# Initialize the project id and the keyfile
project_id = "short-cine"
keyfile = "service-key.json"

# Create a credentials object with the keyfile
creds = Google::Cloud::Translate::Credentials.new keyfile

# Create the instance of Google Translate API
$translate = Google::Cloud::Translate.new(
  project_id: project_id,
  credentials: creds
)

# Setting up the config
config_file = File.read('config.json')
CONFIG = JSON.parse(config_file)

DESTINATION_LANGUAGES = CONFIG["destination_languages"]
OUTPUT_FOLDER = CONFIG["output_folder"]
INPUT_FILE_PATH = CONFIG["input_file_path"]

# Read the input JSON and Parse it to Ruby hash
file = File.read(INPUT_FILE_PATH)
enLang = JSON.parse(file)


# The iterator function to loop each and every key of the hash
def translateObject(parent, hash, lang)
  hash.each {|key, value|
  	if value.is_a?(Hash)
     translateObject(key, value, lang)
  	else
  	   value = $translate.translate value, to: lang
  	   hash[key] = value.text
  	   print key + " - " + hash[key] + "\n"
  	end
  }
end

# Looping each destination language and translating each leaf nodes
DESTINATION_LANGUAGES.each do |lang|
	puts "Translating to " + lang
	newLang = JSON.parse(file)

	translateObject(nil, newLang, lang)
	jsonOutput = JSON.pretty_generate(newLang)

	# Storing the final output in sepecific code
	File.open(OUTPUT_FOLDER + "/" + lang + ".json", "w") do |f|
	  f.write(jsonOutput)
	end
end
 
