require "logger"

def json_parse_safe(url, json, logger)

	# The top-level structure of a JSON document is an array or object,
	# and the shortest representations of those are [] and {}, respectively.
	# So valid non-empty json should have two octet
	if json && json.length >= 2
		begin
			return JSON.parse(json)
		rescue JSON::ParserError, TypeError => e
			logger.warn "Not a valid JSON String #{json} for url= #{url}"
			return nil
		end
	else
		return nil
	end
end

# control the API call pace
def sleep_according_to_timer_and_api_call_limit(call_hash, logger)
	# if meet max allowed call count during the time interval
	# sleep until time expires
	while (Time.now.to_i <= call_hash['end_time'].to_i && call_hash['call_count'] >= call_hash['allowed_call_number_during_interval'])
		sleep_sec = (call_hash['end_time'] - Time.now).to_i + 2
		logger.info "API call: sleep #{sleep_sec} seconds till next time interval"
		sleep(sleep_sec)
	end

	if (Time.now.to_i > call_hash['end_time'].to_i)
		# set new time frame
		call_hash["start_time"] = Time.now
		call_hash['end_time'] = call_hash['start_time'] + call_hash['time_interval_in_seconds'] # one minute apart
		#rest the esb call count
		logger.info "reset call count"
		call_hash['call_count'] = 0
	end

	# return changed values
	return call_hash
end