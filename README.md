## Instructions on how to run the code

The server of this project only requires Docker. Please make sure nothing is running locally on port 3000 or 8080 before starting. Once you have cloned this repository, run the following command in the root of this project:

```
docker-compose up
```

To run the client, you will need Node and NPM. Please make sure nothing is running locally on port 3001. Clone https://github.com/camachom/pathrise-client and run the following command:

```
npm start
```

The app is now running locally on `http://localhost:3001/`.

## Third party libraries

The client uses React and the server uses Node/Express. I don't consider these choices significant in terms of my implementation. I picked them because they allow me to focus on the assignment and not on the tooling. 

For my database, I chose Postgres. This was a deliberate choice. All of the job resolution logic is handled by its full text search. The idea is that SQL can deal with data a lot more gracefully than Node. No additional third party libraries were required.

## How it works

All of the job resolution logic is written as triggers. A trigger is a function that runs based on an event such as `INSERT`. Here is my algorithm:

1. Boards are imported
2. A trigger creates a query (removing punctuation to improve accuracy) and saves it as column since it will be reused
3. Jobs are imported
4. A trigger does the following
  - Domain is extracted from URL to improve accuracy
  - Domain is converted into a vector to be used in full text search
  - Search using queries from step 1 and rank results. If there are matches, return top result
  - Otherwise, do a similar process but using company name

## W@hy is this an effective implementation?

- Because all the logic is done in the database layer, the client and server are 'dumb'. This means they are quite easy to extend and scale.
- SQL is better at dealing with data than Node. I did not have to import third parties or use complex regular expressions expressions.
- Search could easily be extended to be more sophisticated. More properties can be added to the vector. Also, we could be selective on what is considered a match. To avoid false-postivites, we could require a very high rank.

## Public URL 

I used Heroku to host this project: https://pathrise-client.herokuapp.com







