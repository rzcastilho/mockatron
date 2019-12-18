# Mockatron [![Build Status](https://travis-ci.org/rzcastilho/mockatron.svg?branch=master "Build Status")](http://travis-ci.org/rzcastilho/mockatron) [![Coverage Status](https://coveralls.io/repos/github/rzcastilho/mockatron/badge.svg)](https://coveralls.io/github/rzcastilho/mockatron)

### The amazing mock server!

Each mock at **Mockatron** is composed of an **Agent** with one or more **Responses**.

You can add one or more **Filters** to your **Agents** to route specific **Requests** to specific **Responses**, and you can define **Request Conditions** on **Requests** using the message body, headers, and query params. **Response Conditions** can be applied to **Responses** filtering by a label, status code, and message body.

The image below illustrates the mock structure.

![Database Diagram](docs/images/Mockatron-Database.svg "Database Diagram")
