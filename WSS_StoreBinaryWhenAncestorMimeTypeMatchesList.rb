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

This WSS demonstrates selectively storing item binaries based on whether they have an
ancestor items which has a mime type specified in a list of mime types.

=end

# Provide a list of ancestor mime types for which
# descendants of those ancestor type will have their binary stored, all other
# items will not have their binary stored!  Note an entry in
# this list must have a value of true to have its descendants' binaries stored!
$store_binary_ancestor_mime_types = {
	"application/vnd.ms-outlook" => true
}

# We can perform initialization here
def nuixWorkerItemCallbackInit
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	source_item = worker_item.getSourceItem
	path = source_item.getPath
	has_appropriate_ancestor = path.any?{|si|$store_binary_ancestor_mime_types[si.getType.getName]}
	if has_appropriate_ancestor
		worker_item.setStoreBinary(true)
	else
		worker_item.setStoreBinary(false)
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end