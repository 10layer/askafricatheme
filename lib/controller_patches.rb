# Add a callback - to be executed before each request in development,
# and at startup in production - to patch existing app classes.
# Doing so in init/environment.rb wouldn't work in development, since
# classes are reloaded, but initialization is not run each time.
# See http://stackoverflow.com/questions/7072758/plugin-not-reloading-in-development-mode
#
Rails.configuration.to_prepare do
    # Example adding an instance variable to the frontpage controller
    GeneralController.class_eval do
        def mycontroller
            @say_something = "Greetings friend"
        end
    end
    HelpController.class_eval do
        def help_out
        end
    end

    RequestController.class_eval do
        def render_new_preview
            message = ""
            
            # if @outgoing_message.contains_email?
            #     if @user.nil?
            #         message += _("<p>You do not need to include your email in the request in order to get a reply, as we will ask for it on the next screen (<a href=\"{{url}}\">details</a>).</p>", :url => (help_privacy_path+"#email_address").html_safe);
            #     else
            #         message += _("<p>You do not need to include your email in the request in order to get a reply (<a href=\"{{url}}\">details</a>).</p>", :url => (help_privacy_path+"#email_address").html_safe);
            #     end
            #     message += _("<p>We recommend that you edit your request and remove the email address.
            #         If you leave it, the email address will be sent to the authority, but will not be displayed on the site.</p>")
            # end
            if @outgoing_message.contains_postcode?
                message += _("<p>Your request contains a <strong>postcode</strong>. Unless it directly relates to the subject of your request, please remove any address as it will <strong>appear publicly on the Internet</strong>.</p>");
            end
            if not message.empty?
                flash.now[:error] = message.html_safe
            end
            render :action => 'preview'
        end
    end
end
