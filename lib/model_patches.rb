# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do

	InfoRequest.class_eval do
		def law_used_full
			return "Promotion of Access to Information Act"
		end
	    def law_used_short
	    	return "PAIA"
	    end
	    def law_used_act
	    	return "Promotion of Access to Information Act"
	    end
	    def law_used_with_a
	       return "A Promotion of Access to Information Act request"
	    end
	end

	OutgoingMessage.class_eval do

		def contains_id?
			/(((\d{2}((0[13578]|1[02])(0[1-9]|[12]\d|3[01])|(0[13456789]|1[012])(0[1-9]|[12]\d|30)|02(0[1-9]|1\d|2[0-8])))|([02468][048]|[13579][26])0229))(( |-)(\d{4})( |-)(\d{3})|(\d{7}))/.match(self.body)
		end

		# Add intro paragraph to new request template
		def default_letter
			default_letter = File.open(File.dirname(__FILE__) + "/views/request/_default_letter.txt").read
			return default_letter
			# return "Blah"
			# return render plain: "Test"
			# return nil if self.message_type == 'followup'
			#"If you uncomment this line, this text will appear as default text in every message"    
		end

		 # We hide emails from display in outgoing messages.
	    def remove_privacy_sensitive_things!(text)
	        text.gsub!(MySociety::Validate.email_find_regexp, "[Email address redacted]")
	        text.gsub!(/(((\d{2}((0[13578]|1[02])(0[1-9]|[12]\d|3[01])|(0[13456789]|1[012])(0[1-9]|[12]\d|30)|02(0[1-9]|1\d|2[0-8])))|([02468][048]|[13579][26])0229))(( |-)(\d{4})( |-)(\d{3})|(\d{7}))/, "[ID number redacted]")
	        text.gsub!(/(\+)?([-\._\(\) ]?[\d]{3,20}[-\._\(\) ]?){2,10}/, "[Telephone number redacted]")
	    end
	end  

	IncomingMessage.class_eval do
		# Remove emails, mobile phones and other details FOI officers ask us to remove.
	    def remove_privacy_sensitive_things!(text)
	        # Remove any email addresses - we don't want bounce messages to leak out
	        # either the requestor's email address or the request's response email
	        # address out onto the internet
	        text.gsub!(MySociety::Validate.email_find_regexp, "[email address]")

	        # Mobile phone numbers
	        # http://www.whatdotheyknow.com/request/failed_test_purchases_off_licenc#incoming-1013
	        # http://www.whatdotheyknow.com/request/selective_licensing_statistics_i#incoming-550
	        # http://www.whatdotheyknow.com/request/common_purpose_training_graduate#incoming-774
	        text.gsub!(/(Mobile|Mob)([\s\/]*(Fax|Tel))*\s*:?[\s\d]*\d/, "[mobile number]")

	        # Remove WhatDoTheyKnow signup links
	        text.gsub!(/http:\/\/#{AlaveteliConfiguration::domain}\/c\/[^\s]+/, "[WDTK login link]")

	        text.gsub!(/(((\d{2}((0[13578]|1[02])(0[1-9]|[12]\d|3[01])|(0[13456789]|1[012])(0[1-9]|[12]\d|30)|02(0[1-9]|1\d|2[0-8])))|([02468][048]|[13579][26])0229))(( |-)(\d{4})( |-)(\d{3})|(\d{7}))/, "[id number]")
	        # Remove things from censor rules
	        self.info_request.apply_censor_rules_to_text!(text)
	    end   
	end   
end
