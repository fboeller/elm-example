# Elm Example

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
