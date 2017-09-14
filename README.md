# qchat
KDB+ end-to-end RSA encrypted chat fun

## Installation

Clone this repo from [here](https://github.com/toosuto-r/qchat).

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

To create a bot server and worker code must be defined in `bots.q` and `worker.q` respectively.
In `bots.q` a help message should be added to `lables` and an input handler should be defined, with its name added to `tf`. The bots name should be added to `workernames`.
In `worker.q` a function to handle the input and make any HTTP requests should be added. This function should return its result to the worker function.

## Contributing

## Credits
This repo is maintained by the creator and chief contributor [toosuto-r](https://github.com/toosuto-r).
Additional commits have been made by:
* [jonathonmcmurray](https://github.com/jonathonmcmurray) (Levenshtein, connect4 and Bitcoin bot)
* [vibronicshark55](https://github.com/vibronicshark55) (Lastfm bot)

## Licence
