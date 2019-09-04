=begin

Copyright 2019 Nuix
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

This WSS demonstrates logic to pull information from a container MSG item down to the separate
item Nuix extracts from it.  This can help better match behavior from other software which may
not extract a serpate record from an MSG like Nuix does.

=end


# We can perform initialization here
def nuixWorkerItemCallbackInit
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	# :pull_properties         => Do we copy down properties from MSG?
	# :pulled_property_prefix  => Differentiate MSG properties pulled down.
	# :pull_digest             => Do we copy MSG MD5 as property to item? Nuix 7.6 and up only!
	# :pull_size               => Do we copy MSG file size as property to item?
	msg_pulldown(worker_item,{
		:pull_properties => true,
		:pulled_property_prefix => "MSG ",
		:pull_digest => true,
		:pull_size => true,
	})
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end

def msg_pulldown(worker_item,options={})
	# Merge user provided options with set of defaults, in case they do
	# not provide some options.
	final_options = {
		:pull_properties => true,
		:pulled_property_prefix => "MSG ",
		:pull_digest => true,
		:pull_size => true,
	}.merge(options)

	# Get associated SourceItem
	source_item = worker_item.getSourceItem
	
	# We will need th parent to copy value from it
	parent_source_item = source_item.getParent
	
	# Nothing more to do if this item has no parent (is an evidence container)
	return if parent_source_item.nil?

	# Check if this item came from an MSG item
	parent_mime_type = parent_source_item.getType.getName
	if parent_mime_type == "application/vnd.ms-outlook-msg"

		parent_properties = parent_source_item.getProperties
		item_properties = source_item.getProperties

		# Do we copy down properties from the MSG item?
		if final_options[:pull_properties]
			parent_properties.each do |key,value|
				# Build name of copied property from prefix and source property name
				destination_name = "#{final_options[:pulled_property_prefix]}#{key}"
				item_properties[destination_name] = value
			end
		end

		# Do we copy down digest from MSG container?
		# IMPORTANT: This only works in 7.6 and up since that is version that
		# SourceItem.getDigests was added!
		if final_options[:pull_digest]
			parent_md5 = parent_source_item.getDigests.getMd5
			item_properties["MSG MD5 Digest"] = parent_md5
		end

		# Do we copy down MSG file size?
		if final_options[:pull_size]
			parent_file_size = parent_source_item.getFileSize
			item_properties["MSG File Size"] = parent_file_size
		end

		# Save our updated properties collection back to item
		worker_item.setItemProperties(item_properties)
	end
end