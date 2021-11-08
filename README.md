# Tipay

To start your Phoenix server:

  * Install dependencies with `mix deps.get`
  * Create and migrate your database with `mix ecto.setup`
  * Install Node.js dependencies with `cd assets && npm install`
  * Start Phoenix endpoint with `mix phx.server`

Now you can visit [`localhost:4000`](http://localhost:4000) from your browser.

Ready to run in production? Please [check our deployment guides](https://hexdocs.pm/phoenix/deployment.html).

## Learn more

  * Official website: https://www.phoenixframework.org/
  * Guides: https://hexdocs.pm/phoenix/overview.html
  * Docs: https://hexdocs.pm/phoenix
  * Forum: https://elixirforum.com/c/phoenix-forum
  * Source: https://github.com/phoenixframework/phoenix

## Tipay Payments
This application is a tickets reservation system.

### Configuration
Provide apropriate ENV vars for these values:
- TPAY_API_KEY
- TPAY_API_PASSWORD
- TPAY_SECURITY_CODE
- TPAY_APP_URL - url used for redirects to frontend app which is separated from the Phoenix

## GraphQL objects
Usually for every mutation result there is a wrapper. It provides a way to detemine whether mutation was successful. 
In case of error, the key `success` is set to false and response object (in this case `offer`) is null. Key `errors` contains JSON string with error messages. 
```elixir
@desc "Result of executing Offer mutation"
  object :offer_mutate_result do
    field :success, non_null(:boolean)
    field :offer, :offer
    field :errors, :json
  end
```

## Vendor registration in the TPay payments system
Each Event is assigned to a specific Vendor. A TPay account is bound for every vendor. Funds from sales are transferred to this account.
Vendors can have only one active account at a time.
If there is no TPay account assigned to Vendor, then Vendor might be registered on demand.

### New account registration
New account registration in TPay is handled by `registerVendorInTpay` mutation.

## Reservation Flow
Create transaction (and instant payment)
- transaction per event
- multiple offers in transaction (belonging to one event)
- customer has multiple transactions for different events, but only one can be paid at once
- sum all reservations (and deduce left offers count)
- verify how much can be reserved (if not enough is left) - test this case

Booking (offerId, qty)
Transaction
Reservation

## Attachments
Configuration allows you to determine images sizes and types. 
Images are converted with imagemagick to webp and jpg.
Attachment role determines whether is it main image, attachment image or document.

Config is stored in `config :tipay, Tipay.EventAttachments.Main`
Fields:
  - image_sizes - desired image sizes after conversion `%{portrait: {200, 300}, landscape: {300, 200}},` where key is the resulting image size
  - min_canvas_size - minimumal allowed original uploaded image size
  - permitted_formats - allowed file formats
  - max_file_size - file size limit

Envirionment variables
`TIVENT_UPLOADS_STORAGE_DIR`

### Tickets
Each customer has a token used for ticket verification. 
Usher (ticket collector) might retrieve tickets assigned to a given event.

### Testing
There is a file `./dev/2021-05-23-test-upload.sh` which can be run for uploads verification.
By default it is uploading file located in `test/__files` folder.

#### Triggers
Database triggers prevent reservation of more than available offer quantity. Triggers are created for offers on UPDATE row and for offer_bookings during INSERT clause.

Both triggers calculate maximum available quantity and limit requested quantity value - for offer sold_qty and offers_booking.qty columns. 

### Testing
All test's commands are defined inside `dev` directory. Tags defined as `@moduletag` determine context for testsuite. It can be defined as larger scope: `integration` or smaller one: `users`. Every GraphQL test must have a `graphql` tag.
Tests can be run with `mix test`. Integraion tests might require special setup (api keys etc). Thus integration tests are excluded by default. To run ingtegration tests, execute `./dev/integration-tests`. 
### GraphQL testing
- test whether desired mutation is available
- implement it's logic
  - store transaction in DB
  - send transaction to the external API

Request
```elixir
{
    userId: 'uuid',
    paymentMethodId: 22,
    acceptRegulations: true,
    offers: [
      {
        id: 'uuidX',
        quantity: 3
      },
      {
        id: 'uuidY',
        quantity:1
      }
    ]
}
```
Response
```elixir
{
  amount: 20.99,
  currency: 'PLN',
  bookingTo: timestamp,
  url: 'https://redirect'
}
```

### BDD Testing
In the directory `test/bdd` specify every case, every path of expected user interaction.
Example:
`test that transaction is sent succesfuly`

- use Given/When/Then terms.
- split BDD for API (GraphQL) and APP cases (if necessary). This approach separates Resolver layer from Application layer. In result it's easier to verify where potential error occurred.

### Testing strategy
Write tests for GraphQL first, and GraphQL resolvers should return mocked data.
Write tests for Contexts.
Then, merge GraphQL and Contexts.
To ease test's maintenance, tests suites may be split by context of usage or by the functionality. Create separate folder named `context` to store context based tests.
