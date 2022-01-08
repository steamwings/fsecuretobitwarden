require 'json'
require 'securerandom'

CONFIG_PATH = './config.json'

if ARGV.length != 1
  puts "Exactly one argument required: filename to process."
  exit
end

output = {folders: [], items: []}
folder_conditions = []

config = JSON.parse(File.read(CONFIG_PATH))
default_folder_id = config["folders"][0]["id"]

# Add folders from config to output
for folder in config["folders"] 
  f = folder.dup()
  f.delete("contains")
  output[:folders].push(f)
end

filename = ARGV[0]
contents = JSON.parse(File.read(filename))["data"]

# In-memory processing of contents
for _, entry in contents
  item = {
    id: SecureRandom.uuid,
    name: entry["service"],
    favorite: entry["favorite"] == 1,
    fields: []
  }

  if entry["type"] == 1 # Login type
    item["type"] = 1
    uris = []
    if !item["url"].nil?
      uris.push({"match": nil, "uri": item["url"]})
    end
    item["login"] = {
      "uris": uris,
      "username": entry["username"],
      "password": entry["password"]
    }
  elsif entry["type"] == 2 # Card type
    item["type"] = 3

    expiry_parts = entry["creditExpiry"].split('/') # Assume slashes in the dates
    (month, year) = {
      0 => ["",""],
      1 => ["", expiry_parts[0]],
      2 => expiry_parts,
      3 => [expiry_parts[0], expiry_parts[2]] # Assume American date format (mm/dd/yy)
    }[expiry_parts.length]

    unless year.length == 4
      year = "20" + year # Assume 21st century :)
    end

    item["card"] = {
      "cardholderName": entry["username"],
      "brand": "",
      "number": entry["creditNumber"],
      "expMonth": month,
      "expYear": year,
      "code": entry["creditCvv"]
    }

    if entry["password"] # Add card PIN as hidden field
      item[:fields].push({
        "name": "Card PIN",
        "value": entry["password"],
        "type": 1
      })
    end

  else throw "Unknown Fsecure entry type"
  end

  for folder in config["folders"]
    if item[:name].include?(folder["contains"])
      item[:folderId] = folder["id"]
      break
    end
  end 

  if entry["notes"] # Save notes
    if config["hideNotes"]
      item[:fields].push({
        "name": "Notes from F-Secure",
        "value": entry["notes"],
        "type": 1
      })
    else 
      item["notes"] = entry["notes"]
    end
  end

  output[:items].push(item)
end

IO.write('output.json', JSON.pretty_generate(output))

