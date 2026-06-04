# ``TPANetwork``

A small, dependency-free async HTTP stack built on `URLSession`, with composable request and
response processors.

## Overview

Features describe *what* they want with an ``Endpoint`` and hand it to ``HTTPClient``, which returns
a decoded model or a typed ``NetworkError``. The client composes a fixed pipeline:

```
build request → request processors → URLSession → validate → decode → response processors
```

Cross-cutting concerns are **processors**, not edits to the client:

- ``RequestProcessor`` decorates the outgoing request. Built-ins: ``DefaultHeadersProcessor``,
  ``APIKeyProcessor``, ``AuthTokenProcessor``. A new concern is a new processor.
- ``ResponseProcessor`` reacts to the result (inspect-only). ``UnauthorizedResponseProcessor``
  fires only when an *authenticated* request returns `401` — the seam for token refresh / forced
  sign-out, kept out of the client and out of feature services.

Everything is protocol-fronted (``HTTPClientProtocol``, ``HTTPSession``, ``ResponseDecoder``) so
tests inject a stubbed session or a mock client — no real network required.

## Topics

### Client

- ``HTTPClient``
- ``HTTPClientProtocol``
- ``HTTPSession``

### Describing a request

- ``Endpoint``
- ``HTTPMethod``
- ``HTTPHeader``
- ``HTTPHeaderValue``

### Request processors

- ``RequestProcessor``
- ``DefaultHeadersProcessor``
- ``APIKeyProcessor``
- ``AuthTokenProcessor``

### Responses

- ``ResponseDecoder``
- ``JSONResponseDecoder``
- ``ResponseProcessor``
- ``NetworkResponseContext``
- ``UnauthorizedResponseProcessor``
- ``NetworkError``
