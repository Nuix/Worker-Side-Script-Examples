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

java_import java.io.FileOutputStream
java_import com.itextpdf.text.Document
java_import com.itextpdf.text.pdf.PdfCopy
java_import com.itextpdf.text.pdf.PdfReader

$pdf_mime_types = {
	"application/pdf" => true,
	"application/pdf-mail" => true,
	"application/pdf-portfolio" => true,
}

# Specifies the location that page level PDF files will be saved to.  Note that since the
# page level PDFs generated are processed as individual items into the case, they are effectively
# source data.  Therefore it is best to consider this directory as you would source data.
$page_level_pdf_store = "D:\\SinglePagePdfs"

# Splits a source item (which is a PDF) into a series of PDFs, 1 per
# page in the source PDF.
def split_pdf_source_item(source_item,export_directory)
	generated_files = []
	java.io.File.new(export_directory).mkdirs
	input_stream = source_item.getBinary.getBinaryData.getInputStream
	reader = PdfReader.new(input_stream)
	base_name = File.basename(source_item.getLocalisedName,".pdf")
	pages = reader.getNumberOfPages
	pages.times do |page_number|
		page_number += 1
		output_file = File.join(export_directory,"#{base_name}_Page#{page_number.to_s.rjust(4,"0")}.pdf")
		document = Document.new(reader.getPageSizeWithRotation(page_number))
		writer = PdfCopy.new(document,FileOutputStream.new(output_file))
		document.open
		page = writer.getImportedPage(reader,page_number)
		writer.addPage(page)
		document.close
		writer.close
		generated_files << output_file
	end
	reader.close
	return generated_files
end

# Define our initialization callback
def nuix_worker_item_callback_init
	# Perform some setup here
end

# Define our worker item callback
def nuix_worker_item_callback(worker_item)
	source_item = worker_item.getSourceItem
	mime_type = source_item.getType.getName
	parent_source_item = source_item.getParent
	parent_mime_type = nil
	if parent_source_item.nil? == false
		parent_mime_type = parent_source_item.getType.getName
	end
	guid = worker_item.getItemGuid

	# If the mime type of the current item is a PDF one and the parent is not a PDF mime type
	# then we proceed to split it up.  We check this because later on the single page PDFs
	# we generate will pass through this callback and we don't want the logic to try and split
	# them again, which would result in a sort of recursive looping
	if $pdf_mime_types[mime_type] == true && (parent_mime_type.nil? || !$pdf_mime_types[parent_mime_type])
		puts "Splitting PDF: #{guid}"
		subdir_a = guid[0..2]
		subdir_b = guid[3..5]
		export_directory = File.join($page_level_pdf_store,subdir_a,subdir_b)
		java.io.File.new(export_directory).mkdirs
		generated_files = split_pdf_source_item(source_item,export_directory)
		worker_item.setChildren(generated_files)
	end
end

# Define our closing callback
def nuix_worker_item_callback_close
end