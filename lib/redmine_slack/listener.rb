require 'httpclient'

=begin
	base program is Redmine Slack by Samuel Cormier-Iijima
	 URL : https://github.com/sciyoshi/redmine-slack
=end

class SlackListener < Redmine::Hook::Listener
	def controller_wiki_edit_after_save(context = { })
    project = context[:project]
    page = context[:page]

    user = page.content.author
    project_url = "<#{object_url project}|#{escape project}>"	
    page_url = "<#{object_url page}|#{page.title}>"
    comment = "[#{project_url}] : _Wiki_ Page update by *#{user}*"

 	channel = channel_for_project project
	url = url_for_project project

		attachment = {}
		attachment[:text] = "Update Page : #{page_url} \n comment : #{page.content.comments}"
	speak comment, channel, attachment, url
  	end

	def speak(msg, channel, attachment=nil, url=nil)
		url = Setting.plugin_redmine_slack[:slack_url] if not url
		username = Setting.plugin_redmine_slack[:username]
		icon = Setting.plugin_redmine_slack[:icon]

		params = {
			:text => msg,
			:link_names => 1,
		}

		params[:username] = username if username
		params[:channel] = channel if channel

		params[:attachments] = [attachment] if attachment

		if icon and not icon.empty?
			if icon.start_with? ':'
				params[:icon_emoji] = icon
			else
				params[:icon_url] = icon
			end
		end

		client = HTTPClient.new
		client.ssl_config.cert_store.set_default_paths
		client.ssl_config.ssl_version = "SSLv23"
		client.post url, {:payload => params.to_json}
	end

private
	def escape(msg)
		msg.to_s.gsub("&", "&amp;").gsub("<", "&lt;").gsub(">", "&gt;")
	end

	def object_url(obj)
		Rails.application.routes.url_for(obj.event_url({:host => Setting.host_name, :protocol => Setting.protocol}))
	end

	def url_for_project(proj)
		return nil if proj.blank?

		cf = ProjectCustomField.find_by_name("Slack URL")

		return [
			(proj.custom_value_for(cf).value rescue nil),
			(url_for_project proj.parent),
			Setting.plugin_redmine_slack[:slack_url],
		].find{|v| v.present?}
	end

	def channel_for_project(proj)
		return nil if proj.blank?

		cf = ProjectCustomField.find_by_name("Slack Channel")

		val = [
			(proj.custom_value_for(cf).value rescue nil),
			(channel_for_project proj.parent),
			Setting.plugin_redmine_slack[:channel],
		].find{|v| v.present?}

		if val.to_s.starts_with? '#'
			val
		else
			nil
		end
	end
end
