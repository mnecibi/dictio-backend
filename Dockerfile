#==============
# Build Stage
#==============
FROM bitwalker/alpine-elixir:1.13 as build

# Copy the source folder into the Docker image
COPY . .

# Install dependencies and build Release
RUN export MIX_ENV=prod && \
    rm -Rf _build && \
    rm -Rf /export && \
    mix local.hex --force && \
    mix local.rebar --force && \
    mix deps.get --only prod && \
    mix release dictio

# Extract Release archive to /rel for copying in next stage
RUN APP_NAME="dictio" && \
    RELEASE_DIR=`ls -d $HOME/_build/prod/rel/$APP_NAME` && \
    mkdir /export && mkdir /export/dictio && \
    cp -rf $RELEASE_DIR /export/dictio

#====================
# Deployment Stage
#====================
FROM build

# Set environment variables
ENV HOME=/opt/app
ENV MIX_ENV=prod

WORKDIR $HOME

USER root

VOLUME $HOME/dictio/files

# Copy and Release files from the previous stage
COPY --from=build /export/* $HOME

#Set default entrypoint and command
CMD ["/opt/app/dictio/bin/dictio", "start"]