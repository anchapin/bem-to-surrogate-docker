# AUTHOR:           Nicholas Long
# DESCRIPTION:      OpenStudio Server Docker Container
# TO_BUILD_AND_RUN: docker-compose up
# NOTES:            Currently this is one big dockerfile and non-optimal.

#may include suffix
ARG OPENSTUDIO_VERSION=3.6.1
FROM nrel/openstudio:3.6.1 as base
MAINTAINER Nicholas Long nicholas.long@nrel.gov

ENV DEBIAN_FRONTEND=noninteractive
# Install required libaries.
#   realpath - needed for wait-for-it
RUN apt-get update && apt-get install -y wget gnupg \
    && apt-get update \
    && apt-get install -y --no-install-recommends \
        build-essential \
        bzip2 \
        dos2unix \
        curl \
        git \
        libyaml-dev \
        python-numpy \
        python3-numpy \
        tar \
        unzip \
        wget \
        zip \
    && rm -rf /var/lib/apt/lists/*

# Specify a couple arguments here, after running the majority of the installation above
ARG rails_env=docker
ARG bundle_args="--with development test"

# extension gem testing
# ENV FAVOR_LOCAL_GEMS 1

#### OpenStudio Server Code
# First upload the Gemfile* so that it can cache the Gems -- do this first because it is slow
ADD openstudio-bem-to-surrogate-gem/bin /opt/openstudio-bem-to-surrogate-gem/bin
ADD openstudio-bem-to-surrogate-gem/Gemfile /opt/openstudio-bem-to-surrogate-gem/Gemfile
ADD openstudio-bem-to-surrogate-gem/runner.conf.gha /opt/openstudio-bem-to-surrogate/runner.conf
ADD openstudio-bem-to-surrogate-gem/openstudio-bem-to-surrogate.gemspec  /opt/openstudio-bem-to-surrogate-gem/openstudio-bem-to-surrogate.gemspec
ADD openstudio-bem-to-surrogate-gem/Rakefile /opt/openstudio-bem-to-surrogate-gem/Rakefile
ADD openstudio-bem-to-surrogate-gem/configs.yml.template /opt/openstudio-bem-to-surrogate-gem/configs.yml.template
ADD openstudio-bem-to-surrogate-gem/bin /opt/openstudio-bem-to-surrogate-gem/bin/
ADD openstudio-bem-to-surrogate-gem/doc_templates /opt/openstudio-bem-to-surrogate-gem/doc_templates
ADD openstudio-bem-to-surrogate-gem/lib /opt/openstudio-bem-to-surrogate-gem/lib
ADD openstudio-bem-to-surrogate-gem/spec /opt/openstudio-bem-to-surrogate-gem/spec
ADD openstudio-bem-to-surrogate-gem/.rubocop.yml /opt/openstudio-bem-to-surrogate-gem/.rubocop.yml
ADD openstudio-bem-to-surrogate-gem/.pre-commit-config.yaml /opt/openstudio-bem-to-surrogate-gem/.pre-commit-config.yaml
# ... (previous instructions)

# Set work directory to the project root
WORKDIR /opt/openstudio-bem-to-surrogate-gem

# Show environment
RUN ruby -v
RUN openstudio openstudio_version
RUN openstudio gem_list

# Fetch updated gem metadata (important before installing)
RUN git config --global --add safe.directory '*'
RUN gem install bundler -v '2.1.4'
RUN bundle -v
RUN bundle config set --local path .bundle

# Install gems 
RUN bundle install 

# ... (rest of your Dockerfile, removing any git operations)

# Run core tests
# RUN bundle exec rspec spec/tests

# List and update measures (consider removing these for a cleaner production image)
RUN echo "List Measures"
RUN bundle exec rake openstudio:list_measures
RUN echo "Update measures"
RUN bundle exec rake openstudio:update_measures

# Test with openstudio (uncomment if needed)
# RUN bundle exec rake openstudio:test_with_openstudio

# Collect stats, display and check for failures (uncomment if needed)
# RUN test_dir=$(find -type d -name "test_results")
# RUN echo $test_dir
# RUN mv $test_dir .
