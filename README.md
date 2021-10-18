[![ci workflow](https://github.com/rzcastilho/mockatron/actions/workflows/ci.yml/badge.svg)](https://github.com/rzcastilho/mockatron/actions/workflows/ci.yml/badge.svg)
[![coverage status](https://coveralls.io/repos/github/rzcastilho/mockatron/badge.svg)](https://coveralls.io/github/rzcastilho/mockatron)
[![GitHub tag (latest by date)](https://img.shields.io/github/v/tag/rzcastilho/mockatron)](https://github.com/rzcastilho/mockatron/releases)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/rzcastilho/mockatron/blob/master/LICENSE)

# Mockatron

![Mockatron Logo](docs/images/mockatron-logo.png "Mockatron Logo")

## The amazing mock server!!!

Each mock at **Mockatron** is composed of an **Agent** with one or more **Responses**.

You can add one or more **Filters** to your **Agents** to route specific **Requests** to specific **Responses**, and you can define **Request Conditions** on **Requests** using the message body, headers, query params, and path params. **Response Conditions** can be applied to **Responses** filtering by a label, status code, and message body.

The image below illustrates the mock structure.

![Database Schema](docs/images/database-schema.svg "Database Schema")
