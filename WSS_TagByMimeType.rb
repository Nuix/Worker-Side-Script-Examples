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