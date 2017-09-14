# qchat
KDB+ end-to-end RSA encrypted chat fun

## Installation

Clone this repo

## Usage

### Server
The main server file is `chatter.q`. This file contains a list of and loads the necessary files required to run the chat process.
```
q chatter.q -p 1234 -admin user1 -users user1-user2
```

### Client
With challenge mode off clients may connect by opening a q session and connecting to the server process:
```
hopen 1234
```
On first connection the client will be asked to provide public and private keys in the format `n e` where `n` is the shared component between the keys.
If sucessful keys are provided the client will be connected.

### Interaction
Client can type a `\h` to access a help message and `\` to access a list of functions, a selection of which are detailed belowe:
`\q` quit
`\u` list active users
`\c` change username colour

## Bots
Bots provide additional functionality and are handled by `worker.q`, which is a separate process spun up if `workeron` is true. This allows the bots to make web requests that may potentially hang before return the result to the chat.
Several chat bots are available that may be called from backslash `\` commands.

Bots require a function to handle backslash requests on the server. This function in turn should pass data to a handler function on the worker process which makes HTTP requests (if required).

## Contributing

## Credits
[toosuto-r](https://github.com/toosuto-r)
[jonathonmcmurray](https://github.com/jonathonmcmurray)
[vibronicshark55](https://github.com/vibronicshark55)

## Licence
