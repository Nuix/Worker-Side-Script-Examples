=begin

Copyright 2023 Nuix
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

This WSS demonstrates skipping processing of items based on their mime type.

=end

# List of mime types to exclude
$excluded_mime_types = [
	"text/plain" # Skip plain text files
]

# We can perform initialization here
def nuixWorkerItemCallbackInit
	# We are going to build a faster lookup based on the list the user provided
	$excluded_mime_type_lookup = {}
	puts "WSS Excluded Mime Types:"
	$excluded_mime_types.each do |mime_type|
		puts mime_type
		$excluded_mime_type_lookup[mime_type.strip] = true
	end
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	# Get associated SourceItem
	source_item = worker_item.getSourceItem
	# Get the mime type
	mime_type = source_item.getType.getName
	# Does our mime type list contain this mime type?
	if $excluded_mime_type_lookup.has_key?(mime_type)
		# It does, tell Nuix not to process it into the case
		worker_item.setProcessItem(false)
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end