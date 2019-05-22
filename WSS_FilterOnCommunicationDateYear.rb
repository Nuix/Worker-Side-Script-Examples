$min_year = 2001
$max_year = 2001

# Define our worker item callback
def nuix_worker_item_callback(worker_item)

    # Get the associated SourceItem
    source_item = worker_item.getSourceItem

    # Get the communication object
    communication = source_item.getCommunication
    
    # Check that we actually got a communication for this item
    if !communication.nil?
        # Get communication date
        date_time = communication.getDateTime
        # Get the year
        year = date_time.getYear
        # Are we outside our range?
        if year < $min_year || year > $max_year
            # We're outside our range, diable processing this item
            worker_item.setProcessItem(false)
        end
    end
end