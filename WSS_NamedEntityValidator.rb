=begin

Copyright 2020 Nuix
Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at
    http://www.apache.org/licenses/LICENSE-2.0
Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.

Visit GitHub for more examples: https://github.com/Nuix/Worker-Side-Script-Examples

This worker script demonstrates ways to control Named Entity extraction.
In addition to the installed entity types, the script adds an entity type for SWIFT codes.
Entities for phone-num are only created if the item's text contains 'phone', 'mobile,' or 'call.'
Entities for personal-id-num are normalized to include dashes. i.e. 123-45-6789 rather than 123456789 or 123 45 6789.

=end

java_import java.util.regex.Pattern

$entity_types = { 'swift' => '[A-Z]{6}[0-9A-Z]{2}([0-9A-Z]{3})?' }

$validation_terms = { 'phone-number' => %w[phone mobile call] }

# Convert any $entity_types regular expression strings to Patterns.
def nuixWorkerItemCallbackInit
  $entity_types.transform_values! do |pattern|
    next pattern if pattern.is_a?(Java::JavaUtilRegex::Pattern)

    Pattern.compile(pattern)
  end
end

# Scans item text for entities.
# Includes entity for SWIFT codes.
# Requires that phone-number entities must come from an item that contains 'phone', 'mobile', or 'call.'
# Normalizes personal-id-num entities, by adding dashes.
#
# @param worker_item [WorkerItem] the item being processed
def nuixWorkerItemCallback(worker_item)
  installed_entities = worker_item.get_installed_named_entity_types
  entity_types = installed_entities.to_h.merge($entity_types)
  # Scan item text for matches
  matches = worker_item.scan_item_text(entity_types)
  puts "Found #{matches.size} matches"
  return if matches.empty?

  # Iterate and check matches
  entities = validate(worker_item, matches)
  # Add validated entities
  worker_item.add_named_entities(entities)
end

# Normalize SSN by adding dashes or replacing spaces with dashes.
# i.e. 123456789 and 1234 56 789 => 123-45-6789
#
# @param entity [Entity] the extracted entity
# @param worker_item [WorkerItem] the item being processed
# @return [Entity] normalized ssn entity
def ssn_entity(entity, worker_item)
  value = entity.get_value
  return entity if value.include?('-')

  if value.length == 9
    # Add dash if no separator
    value = "#{value[0, 3]}-#{value[4, 2]}-#{value[6, 4]}"
  else
    # Convert space to dash
    value.gsub!(' ', '-')
  end
  worker_item.create_entity(entity.get_type, value)
end

# Iterates and checks entities.
#
# @param worker_item [WorkerItem] the item being processed
# @param matches [Array] extracted entities
# @return [Array] validated entities
def validate(worker_item, matches)
  source_item = worker_item.get_source_item
  valid_entities = []
  # Check the item for $validation terms
  valid_for = validate_item(source_item)
  # Iterate and check that matches are valid
  matches.each do |entity|
    # Check the entity type is valid for the item
    type = entity.get_type
    next unless validate_match(type, valid_for)

    # Normalize personal-id-num
    entity = ssn_entity(entity, worker_item) if type == 'personal-id-num'
    valid_entities << entity
  end
  valid_entities
end

# Validates item by checking if it contains $validation_terms.
#
# @param source_item [SourceItem] the source item being processed
# @return [Array<String>] list of entiity types with included terms
def validate_item(source_item)
  valid_for = []
  text = source_item.get_text.to_string
  $validation_terms.each do |entity_type, terms|
    # Check if item text includes $validation_terms
    valid_for << entity_type if terms.any? { |term| text.include? term }
  end
  valid_for
end

# Checks if the match is a valid entity for the item.
#
# @param entity_type [String] the type of the entity
# @param valid_for [Array] list of entity types the item has been validated for
# @return [True, False] if the match is valid
def validate_match(entity_type, valid_for)
  # valid if there are no validation terms for the entity type
  return true unless $validation_terms.keys.include?(entity_type)

  # valid if the item is valid for the entity type
  valid_for.include?(entity_type)
end
