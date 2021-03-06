note

	description:

		"List contents of bucket"

	library: "s3 tools"
	author: "Berend de Boer <berend@pobox.com>"
	copyright: "Copyright (c) 2011, Berend de Boer"
	license: "MIT License (see LICENSE)"
	date: "$Date$"
	revision: "$Revision$"


class

	S3_LS


inherit

	S3_TOOL


create

	make,
	make_no_rescue


feature {NONE} -- Initialize

	make_no_rescue
			-- Initialize. and run.
		do
			parse_arguments
			list_files
		end


feature -- Commands

	list_files
		local
			s3: S3_CLIENT
			query: STRING
		do
			create s3.make (access_key_id, secret_access_key)
			if region.occurrences > 0 then
				s3.set_region (region.parameter)
			end
			query := "?"
			if max_keys.occurrences > 0 then
				query.append_string ("max-keys=" + max_keys.parameter.out)
			end
			if prefix_option.occurrences > 0 then
				if query.count > 1 then
					query.append_character ('&')
				end
				query.append_string ("prefix=" + prefix_option.parameter)
			end
			if delimiter.occurrences > 0 then
				if query.count > 1 then
					query.append_character ('&')
				end
				query.append_string ("delimiter=" + delimiter.parameter)
			end
			s3.get ("/" + bucket.parameter + query)
			s3.read_response_with_redirect
			if not s3.is_response_ok then
				stdout.put_line ("Response code: " + s3.response_code.out)
			end
			stdout.put (s3.body.as_string)
		end


feature -- Access

	delimiter: AP_STRING_OPTION
			-- Limits results to ????

	max_keys: AP_INTEGER_OPTION
			-- Whatever you specify, Amazon might still truncate the results

	prefix_option: AP_STRING_OPTION
			-- Limits results to those starting with this prefix


feature {NONE} -- Argument parsing

	parse_arguments
		local
			parser: AP_PARSER
		do
			parser := new_default_parser (once "s3ls 0.1.0 (c) by Berend de Boer <berend@pobox.com>%NList contents of bucket.")
			create max_keys.make ('m', "max-keys")
			max_keys.set_description ("Maximum number of entries to return.")
			parser.options.force_last (max_keys)
			create prefix_option.make ('p', "prefix")
			prefix_option.set_description ("Limit entries to those starting with this prefix.")
			parser.options.force_last (prefix_option)
			create delimiter.make ('d', "delimiter")
			delimiter.set_description ("Limit entries to those.")
			parser.options.force_last (delimiter)
			do_parse_arguments (parser)
		end


end
