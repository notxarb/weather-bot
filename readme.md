# weather-bot
This is a simple slack bot that utilizes the accuweather api to fetch current weather according to the zip code the user inputs.

This adds a command /weather to a slack channel.

This utilizes terraform cloud, and github actions to automate deploys and requires a few environment variables to be set to work properly

The github actions needs to have the following secrets configured:
* TF_API_TOKEN - API token for terraform cloud
* TF_VAR_ACCUWEATHER_API_KEY - API key for accuweather
* TF_VAR_SLACK_APP_TOKEN - Slack app token
* TF_VAR_SLACK_BOT_TOKEN - Slack bot token

The following variables need to be configured in terraform cloud:
* AWS_ACCESS_KEY_ID - AWS access key id
* AWS_SECRET_ACCESS_KEY - AWS secret access key
* ACCUWEATHER_API_KEY - Accuweather API key
* SLACK_APP_TOKEN - Slack app token
* SLACK_BOT_TOKEN - Slack bot token