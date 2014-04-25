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
		# Add intro paragraph to new request template
		def default_letter
			return File.open(File.dirname(__FILE__) + "/views/request/_default_letter.txt").read
			# return render :partial => "default_letter"
			# return nil if self.message_type == 'followup'
			#"If you uncomment this line, this text will appear as default text in every message"    
		end
	end        
end
