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

# If an item's name contains an extension we don't want to process
# we will tell the worker not to process that item.  Note since we are using
# the item's name, this only really effectively filters data for which the item's
# name in Nuix contains the item's extension.

# List of extensions we don't want to process.  Provide then extension
# without period, map call will convert it into regex for .ext anchored to end
# of input ($).
$excluded_extensions = [
	"plist",
	"cab",
].map{|e|/\.#{e}$/i}

# Define our worker item callback
def nuix_worker_item_callback(worker_item)
	# Get the associated SourceItem
	source_item = worker_item.getSourceItem

	# Get the item's name
	item_name = source_item.getName

	# Does the item name match our exclusion test?
	if $excluded_extensions.any?{|e|item_name =~ e}

		# It does, exclude it from processing
		worker_item.setProcessItem(false)

		# This will be written to worker log
		puts "Excluding item with name: #{item_name}"
	end
end