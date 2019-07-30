Worker Side Script Examples
===========================

This repository contains some example Worker Side Scripts (WSS) for use with Nuix to customize loading data.

## What is a Worker Side Script?

When processing data in Nuix, you can provide a Worker Side Script (WSS) to customize some aspects of how that data is processed.  A very simplified workflow for a given worker could be imagined to be:

- Worker is assigned a piece of data to process
- The worker processes that data, obtaining metadata
- Metadata is written to the Nuix case

A worker side script allows you to intervene in this process with a callback:

- Worker is assigned a piece of data to process
- The worker processes that data, obtaining metadata
	- Worker side script is provided processed data, allowing it to be inspected, modified, skipped, etc
- Metadata is written to the Nuix case

A WSS does this by providing 1 or more callbacks:

- `nuixWorkerItemCallback(worker_item)` - Called once for each item processed by a given worker.  When called, it is provided that item's data in the form of a [WorkerItem](https://download.nuix.com/releases/desktop/stable/docs/en/scripting/api/nuix/WorkerItem.html) object.  Using methods on the WorkerItem, your code may modify things about that data or selectively determine what (if anything) finds its way into the final case.
- `nuixWorkerItemCallbackInit` - Called once before processing begins, allowing your code to perform any initialization you may need to perform.
- `nuixWorkerItemCallbackClose` - Called once after processing has completed, allowing your code to perform any cleanup you may need to perform.

## Basic Examples

In Ruby a barebones example might look like the following:

```ruby
def nuixWorkerItemCallbackInit
	# Perform inialization work here
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	# Analyze the item being processed and do something with this information like:
	# - Skip this item
	# - Add tags and/or custom metadata
	# - Modify the Hash/Map of metadata
	# - etc...
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
	# Perform cleanup work here
end
```

Here is a contrived example:

```ruby
def nuixWorkerItemCallbackInit
	$email_count = 0
end

# Define our worker item callback
def nuixWorkerItemCallback(worker_item)
	source_item = worker_item.getSourceItem
	if source_item.getKind.getName == "email"
		worker_item.addTag("Email Item")
		$email_count += 1
	end
end

# We can perform cleanup here if we need to
def nuixWorkerItemCallbackClose
	puts "This worker found #{email_count} emails during processing"
end
```

## Using a Worker Side Script

### As a Script via the GUI

The processing settings dialog has a tab labelled **Worker Script** which allows you to past a worker side script to be used during processing.

![image](https://user-images.githubusercontent.com/11775738/60054640-f4057980-968f-11e9-967e-8a7b069823be.png)

**Note:** Make sure the correct language is checked!

### As a Script via the API

A script may provide a worker side script by passing the **code** of the script as a string setting while calling [Processor.setProcessingSettings].  This can be done inline in the same file like so using a Ruby [heredoc](http://ruby-doc.org/core-2.2.0/doc/syntax/literals_rdoc.html#label-Here+Documents):

```ruby
# Define the WSS ruby source as a multi line string inline to the main Ruby script
worker_side_script_code = <<CODE

# Define our worker item callback
def nuix_worker_item_callback(worker_item)
	# Do interesting things here
end

CODE

# Define our settings Hash
processing_settings = {
	# Other settings here...
	"workerItemCallback" => "ruby:"+worker_side_script_code,
	# Other settings here...
}

processor.setProcessingSettings(processing_settings)
```

**Note**: The script source code is prefixed with the scripting language of the code being provided, followed by a colon and then the worker side script code as a string.

Storing your worker side script inline as demonstrated in the previous example quickly becomes impractical as the worker side script gets more complex.  A better approach is to store the worker side script code in a separate file and load it:

```ruby
# Define path to a file containing worker side script code
path_to_wss = 'C:\NuixStuff\MyWorkerSideScriptCode.rb'
worker_side_script_code = File.read(path_to_wss)

# Define our settings Hash
processing_settings = {
	# Other settings here...
	"workerItemCallback" => "ruby:"+worker_side_script_code,
	# Other settings here...
}

processor.setProcessingSettings(processing_settings)
```

### As a Java class via the API

It is also possible to use a Java class as a worker side "script".  The first step is to create a Java class which implements [Consumer&lt;WorkerItem&gt;](https://docs.oracle.com/javase/8/docs/api/java/util/function/Consumer.html) and [AutoCloseable](https://docs.oracle.com/javase/8/docs/api/java/lang/AutoCloseable.html).

```java
package com.mycompany.worker;

public class WorkerItemConsumer implements Consumer<WorkerItem>, AutoCloseable {
	// Class constructor
	public WorkerItemConsumer() {
		// Initialization happens here
	}
	
	// This method is provided by the generic Consumer interface
	@Override
	public void accept(WorkerItem workerItem) {
		// Worker side logic here
	}
	
	// This method is provided by the AutoCloseable interface
	@Override
	public void close() throws Exception {
		// Cleanup/shutdown logic here
	}
}
```

Next you will need to compile this code into a Java JAR file and place the compiled file in the `lib` sub directory of your Nuix installation.  This step is important to ensure that when the worker processes are started they have access to the JAR on their class path (which will be the Nuix `lib` sub-directory).

From your script you specify the callback in a similar manner, but instead specify `java` as the language and the *fully qualified class name (including package)* where you previously specified the worker side script code.

```ruby
# Define our settings Hash
processing_settings = {
	# Other settings here...
	# Specify Java and fully qualified path name to our Java class
	"workerItemCallback" => "java:com.mycompany.worker.WorkerItemConsumer",
	# Other settings here...
}

processor.setProcessingSettings(processing_settings)
```