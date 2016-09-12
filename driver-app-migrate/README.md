## Drive The Vote mobile driver app

A React/Redux app for claiming available rides.

### Get Started
####`npm install`
This installs all depedencies needed for running the app locally.

### Develop with a local Rails API
####Setup drive.vote
Clone the [drive.vote repo](https://github.com/devprogress/drive.vote) and follow environment setup instructions from the [wiki](https://github.com/devprogress/drive.vote/wiki/Dev-environment-setup).

####Start the FE Node server
With the Rails server already running, run `npm start`.

####Point to the correct `bundle.js` in the /driving Rails view
Set via `/app/views/driving/index.html.haml` in the drive.vote Rails repo, typically this should be `http://localhost:3001/static/js/bundle.js` for local development. Any changes to the FE code will be visible on the rails app after refreshing the page.



