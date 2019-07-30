# Copyright 2019 Nuix
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#     http://www.apache.org/licenses/LICENSE-2.0
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

# Hash of mime types and the tag to apply to each
$mime_type_tags = {
	"message/rfc822" => "RFC822 Email",
}

# We can perform initialization here
def nuixWorkerItemCallbackInit
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	# Get associated SourceItem
	source_item = worker_item.getSourceItem
	# Get the mime type
	mime_type = source_item.getType.getName
	# Does our mimetype/tag list contain this mime type?
	if $mime_type_tags.key?(mime_type)
		# Get the tag corresponding to this mime type
		tag = $mime_type_tags[mime_type]
		# Apply the tag
		worker_item.addTag(tag)
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
end