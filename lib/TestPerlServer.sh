

# Note: before running the Math server, we need to start the mock Execution Engine


# we need to set the KB_DEPLOYMENT_CONFIG, which should be setup within a KBase deployment

# the config needs to include a config specifying the Execution Engine URL to submit
# long running async tasks (note that the URL can also be setup as an environment variable)
export KB_DEPLOYMENT_CONFIG=../deploy.cfg

# start the service
plackup Math.psgi