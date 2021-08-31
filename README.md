# Elm Example

This repository aims to show how development looks like in Elm.

## Development

Start the build watch job, an http server and a mock server.

```bash
$ npm run build-watch
$ npx http-server
$ npx mockserver -p 4200 -m './mocks'
```

Open [http://localhost:8080](http://localhost:8080).

## Tests

To test, start the test watch job.

```bash
$ npm run test-watch
```

## Agenda

* Elm is a pure functional programming languages.
* Elm can not and does not have components.
* Elm is great for microfrontends.
* Basic Elm syntax
    * Function syntax
    * ADTs and pattern matching
* The example application
* Model and view
* Msg and update
* Retrieving data from the backend
* Decoding json
* Testing
