# ------ BUILDER ------
FROM node:18 as builder

# Set workdir where the application to build will reside
WORKDIR /src

# Copy all files over to the workdir of the build process
ADD . .

# Install dependencies and build the application
RUN npm install && npm run build

# ------ RUNNER ------
FROM registry.access.redhat.com/ubi8/nodejs-18

ENV PORT=8888

COPY --from=builder /src/dist ./dist
COPY --from=builder /src/node_modules ./node_modules
COPY --from=builder /src/package.json ./package.json

# Change user to non root
USER 1000

EXPOSE $PORT

ENTRYPOINT ["npm", "run", "start:prod"]