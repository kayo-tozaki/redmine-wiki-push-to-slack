require 'redmine'

require_dependency 'redmine_slack/listener'

Redmine::Plugin.register :redmine_slack do
	name 'Redmine Wiki push to Slack'
	author 'kayo_tozaki'
	url 'https://github.com/sciyoshi/redmine-slack'
	author_url 'http://kayo-tozaki.hatenablog.com'
	description 'Slack chat integration and adaption Wiki push'
	version '0.1.1'

	requires_redmine :version_or_higher => '0.8.0'

	settings \
		:default => {
			'callback_url' => 'http://slack.com/callback/',
			'channel' => nil,
			'icon' => 'https://raw.github.com/sciyoshi/redmine-slack/gh-pages/icon.png',
			'username' => 'redmine',
			'display_watchers' => 'no'
		},
		:partial => 'settings/slack_settings'
end
