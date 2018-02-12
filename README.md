# JSON Translator
This project is mainly to help developers translate their JSON files which is commonly issed for localization. It also support any level of nested JSON files.

### How to use.
__Step 1__
Setup Google Transalte API and create service keys for your project. Refer [https://cloud.google.com/translate/docs/reference/libraries](https://cloud.google.com/translate/docs/reference/libraries)

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
