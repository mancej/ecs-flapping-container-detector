#### Flapping Container Detector

Detects repeatedly crashing ECS containers due to failed health checks or any other reason and submits notifications to 
slack. Notifications can be temporarily suppressed via a Slack drop-down menu to give users time to remediate. Requires 
configuration of your own Slack Application and integration of it to your Slack environment.


Installation & Config:

1) Checkout project.
2) Configure Slack Application (see README on slack configuration)
3) Configure config.tfvars 
4) 