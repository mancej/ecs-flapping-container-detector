#### Flapping Container Detector

Detects repeatedly crashing ECS containers due to failed health checks or any other reason and submits notifications to 
Slack. Notifications can be temporarily suppressed via a Slack drop-down menu to give users time to remediate. Requires 
configuration of your own Slack Application and integration of it to your Slack environment.

### Below you can see a visual workflow of the Slack notification and alarm suppression.

#### First Alert
![Alarm Notification](/docs/images/FlappingAlarm.png?raw=true "Alarm Notification")

#### User may then suppress the alarm
![Suppression Options](/docs/images/SuppressDropdown.png?raw=true "Suppression Options")

#### User must accept confirmation dialog (this text is configurable)
![Confirmation](/docs/images/ConfirmationModal.png?raw=true "Confirmation")

#### Channel is updated with the user's confirmation
![Updated Alarm](/docs/images/AlarmAfterSuppression.png?raw=true "Updated Alarm")


#### Local Requirements:
1) Terraform 0.11.7 or later (https://www.terraform.io/intro/getting-started/install.html)
2) AWS CLI (https://aws.amazon.com/cli/)


Homebrew installation of dependencies:

`brew install terraform`

`brew install aws-cli`


#### Installation & Config:

1) Create a new Slack application: See [Slack App Setup Guide](/docs/slack_app_setup.md "Slack App Setup Guide")
2) Deploy via Terraform: See [Terraform Deployment Guide](/docs/deployment_guide.md "Terraform Deployment Guide")
3) Post Deploy Slack configuration: See [Slack App Setup Guide](/docs/slack_app_setup.md "Slack App Setup Guide") parts 4 and 5.


#### Any and all feedback appreciated!