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

# Visit GitHub for more examples: https://github.com/Nuix/Worker-Side-Script-Examples

# This WSS will tag items which have an MD5 present in an annotation DB file previously generated
# and populated with tags using the script "Annotation Export/Import":
# https://github.com/Nuix/Annotation-Export-Import
#
# *** IMPORTANT ***
# This Worker Side Script (WSS) requires the file SuperUtilities.jar to be accessible to the workers.
# Without this file, the class providing access to the annotation DB will not be accessible
# to the workers and processing will error on every item.  You can obtain a copy of this JAR file here:
# https://github.com/Nuix/SuperUtilities/releases
# Once you have a copy of this file, either copy it into the "lib" sub-directory of you Nuix install, for
# example: C:\Program Files\Nuix\Nuix 7.8\lib
# Or make sure you provide a valid full file path to the JAR file in the global variable $superutilities_jar_path

# Specify where the AnnotationRepository SQLite DB file is on the file system
$annotations_db_file = "D:\\Temp\\Annotations.db"

# Specifies where the required SuperUtilities.jar file can be located.  Note that you can provide a value of
# nil for this variable, but then the file SuperUtilities.jar must have been previously copied to the 'lib'
# sub-directory of your Nuix install.
$superutilities_jar_path = "D:\\Temp\\SuperUtilities.jar"

# Whether we should verbosely log what tags we are applying
$verbose = false

# We will initialize this in the init method
$repo = nil

# We can perform initialization here
def nuixWorkerItemCallbackInit
	if $superutilities_jar_path.nil? == false
		require $superutilities_jar_path
	end
	java_import com.nuix.superutilities.annotations.AnnotationRepository
	$repo = AnnotationRepository.new($annotations_db_file)
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	# Get this item's MD5
	md5 = worker_item.getDigests.getMd5
	# Does this item actually have an MD5 value?
	if md5.nil? == false
		tags = $repo.getTagsForMd5(md5)
		if $verbose
			puts "Found #{tags.size} tags for item with MD5 #{md5}: #{tags.join("; ")}"
		end
		tags.each do |tag|
			worker_item.addTag(tag)
		end
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
	# We need to close connections to the SQLite DB file by
	# calling the AnnotationRepository.close method when we are done.
	if $repo.nil? == false
		$repo.close
	end
end