# JSON Translator
This project is mainly to help developers translate their JSON files which is commonly used for localization. It also support any level of nested JSON files.

### How to use.
__Step 1__
Setup Google Translate API and create service keys for your project. Refer [https://cloud.google.com/translate/docs/reference/libraries](https://cloud.google.com/translate/docs/reference/libraries)

Ensure to enable the "Translate" API in the API tab of GCP.

__Step 2__
Install the libraries

```
bundle install
```

__Step 2__
Set your configuration in `config.json`
- `destination_languages` : Array of output language codes
- `output_folder` : Folder to save output json
- `input_file_path` : The source language JSON
- `google_project_id` : Google Cloud Project ID
- `service_key_path` : Service Key file of Google Cloud Project

__Step 3__
Run the translate file with ruby.

```
ruby translate.rb
```

__Step 4__
For Rails devs, use the t.rb file to convert input folder to output folder. This is smart enough to translate only from "en.yml" files, so you just copy your entire locale folder from your Rails project and dump it into the "input" folder. The output will contain the en files and your selected langauges files. Copy the output folder to your locales folder and merge all changes.

```
irb -I .

require 't'

locale_translator = LocaleTranslator.new
locale_translator.convert!
```